/// <summary>
/// Central audit logic that compares the G/L accounts a Value Entry was expected to post to
/// (derived from the inventory and general posting setup) against the accounts it actually
/// posted to (read from the related G/L Entries). Shared by both the report and the list page
/// so the calculation lives in a single place.
/// </summary>
codeunit 50103 "Value Entry Audit Mgt."
{
    Access = Internal;

    /// <summary>
    /// Scans the value entries posted within the given date range, stores every mismatch found in the
    /// Value Entry Audit Result table stamped with the run timestamp, and returns the mismatch count.
    /// Uses partial record loading so it stays efficient over large tables.
    /// </summary>
    /// <param name="StartDate">First posting date to include (0D for no lower bound).</param>
    /// <param name="EndDate">Last posting date to include.</param>
    /// <param name="RunDateTime">Timestamp stamped on every result row from this run.</param>
    /// <returns>The number of mismatches found and stored.</returns>
    procedure RunAudit(StartDate: Date; EndDate: Date; RunDateTime: DateTime): Integer
    var
        ValueEntry: Record "Value Entry";
        AuditResult: Record "Value Entry Audit Result";
        ExpectedInventoryGL: Code[20];
        ExpectedOffsetGL: Code[20];
        ActualInventoryGL: Code[20];
        ActualOffsetGL: Code[20];
        InventoryGLFromPostingGroup: Code[20];
        COGSGLFromPostingGroup: Code[20];
        DirectCostAppliedGLFromPostingGroup: Code[20];
        InventoryAdjmtGLFromPostingGroup: Code[20];
        Mismatch: Boolean;
        MismatchCount: Integer;
    begin
        ValueEntry.SetLoadFields("Entry No.", "Item No.", "Posting Date", "Document No.", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Item Ledger Entry Type");
        ValueEntry.SetRange("Posting Date", StartDate, EndDate);
        if ValueEntry.FindSet() then
            repeat
                CalculateAudit(ValueEntry, ExpectedInventoryGL, ExpectedOffsetGL, ActualInventoryGL, ActualOffsetGL, InventoryGLFromPostingGroup, COGSGLFromPostingGroup, DirectCostAppliedGLFromPostingGroup, InventoryAdjmtGLFromPostingGroup, Mismatch);
                if Mismatch then begin
                    AuditResult.Init();
                    AuditResult."Run Date/Time" := RunDateTime;
                    AuditResult."Value Entry No." := ValueEntry."Entry No.";
                    AuditResult."Item No." := ValueEntry."Item No.";
                    AuditResult."Posting Date" := ValueEntry."Posting Date";
                    AuditResult."Document No." := ValueEntry."Document No.";
                    AuditResult."Expected Inventory G/L" := ExpectedInventoryGL;
                    AuditResult."Actual Inventory G/L" := ActualInventoryGL;
                    AuditResult."Expected Offset G/L" := ExpectedOffsetGL;
                    AuditResult."Actual Offset G/L" := ActualOffsetGL;
                    AuditResult.Insert(true);
                    MismatchCount += 1;
                end;
            until ValueEntry.Next() = 0;

        exit(MismatchCount);
    end;

    /// <summary>
    /// Calculates the expected and actual G/L accounts for a single Value Entry and flags a mismatch.
    /// </summary>
    /// <param name="ValueEntry">The Value Entry to audit.</param>
    /// <param name="ExpectedInventoryGL">Inventory account expected from the inventory posting setup.</param>
    /// <param name="ExpectedOffsetGL">Offset account expected from the general posting setup, based on the entry type.</param>
    /// <param name="ActualInventoryGL">First G/L account actually posted from the related G/L entries.</param>
    /// <param name="ActualOffsetGL">Second G/L account actually posted from the related G/L entries.</param>
    /// <param name="InventoryGLFromPostingGroup">Inventory account configured on the inventory posting setup.</param>
    /// <param name="COGSGLFromPostingGroup">COGS account configured on the general posting setup.</param>
    /// <param name="DirectCostAppliedGLFromPostingGroup">Direct Cost Applied account from the general posting setup.</param>
    /// <param name="InventoryAdjmtGLFromPostingGroup">Inventory Adjmt. account from the general posting setup.</param>
    /// <param name="Mismatch">True when an expected account differs from the actual posted account.</param>
    procedure CalculateAudit(ValueEntry: Record "Value Entry"; var ExpectedInventoryGL: Code[20]; var ExpectedOffsetGL: Code[20]; var ActualInventoryGL: Code[20]; var ActualOffsetGL: Code[20]; var InventoryGLFromPostingGroup: Code[20]; var COGSGLFromPostingGroup: Code[20]; var DirectCostAppliedGLFromPostingGroup: Code[20]; var InventoryAdjmtGLFromPostingGroup: Code[20]; var Mismatch: Boolean)
    begin
        GetExpectedAccounts(ValueEntry, ExpectedInventoryGL, ExpectedOffsetGL, InventoryGLFromPostingGroup, COGSGLFromPostingGroup, DirectCostAppliedGLFromPostingGroup, InventoryAdjmtGLFromPostingGroup);
        GetActualAccounts(ValueEntry, ActualInventoryGL, ActualOffsetGL);
        Mismatch := (ExpectedInventoryGL <> ActualInventoryGL) or (ExpectedOffsetGL <> ActualOffsetGL);
    end;

    local procedure GetExpectedAccounts(ValueEntry: Record "Value Entry"; var ExpectedInventoryGL: Code[20]; var ExpectedOffsetGL: Code[20]; var InventoryGLFromPostingGroup: Code[20]; var COGSGLFromPostingGroup: Code[20]; var DirectCostAppliedGLFromPostingGroup: Code[20]; var InventoryAdjmtGLFromPostingGroup: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        Clear(ExpectedInventoryGL);
        Clear(ExpectedOffsetGL);
        Clear(InventoryGLFromPostingGroup);
        Clear(COGSGLFromPostingGroup);
        Clear(DirectCostAppliedGLFromPostingGroup);
        Clear(InventoryAdjmtGLFromPostingGroup);

        // Inventory account depends on Location Code + Inventory Posting Group (both carried on the Value Entry).
        if ValueEntry."Inventory Posting Group" <> '' then
            if InventoryPostingSetup.Get(ValueEntry."Location Code", ValueEntry."Inventory Posting Group") then begin
                InventoryGLFromPostingGroup := InventoryPostingSetup."Inventory Account";
                ExpectedInventoryGL := InventoryGLFromPostingGroup;
            end;

        if GeneralPostingSetup.Get(ValueEntry."Gen. Bus. Posting Group", ValueEntry."Gen. Prod. Posting Group") then begin
            COGSGLFromPostingGroup := GeneralPostingSetup."COGS Account";
            DirectCostAppliedGLFromPostingGroup := GeneralPostingSetup."Direct Cost Applied Account";
            InventoryAdjmtGLFromPostingGroup := GeneralPostingSetup."Inventory Adjmt. Account";
            ExpectedOffsetGL := ExpectedOffsetAccount(ValueEntry, COGSGLFromPostingGroup, DirectCostAppliedGLFromPostingGroup, InventoryAdjmtGLFromPostingGroup);
        end;
    end;

    local procedure ExpectedOffsetAccount(ValueEntry: Record "Value Entry"; COGSAccount: Code[20]; DirectCostAppliedAccount: Code[20]; InventoryAdjmtAccount: Code[20]): Code[20]
    begin
        case ValueEntry."Item Ledger Entry Type" of
            ValueEntry."Item Ledger Entry Type"::Sale:
                exit(COGSAccount);
            ValueEntry."Item Ledger Entry Type"::Purchase:
                exit(DirectCostAppliedAccount);
            ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.",
            ValueEntry."Item Ledger Entry Type"::"Negative Adjmt.":
                exit(InventoryAdjmtAccount);
            else
                // Fallback for the remaining types (Transfer, Consumption, Output, Assembly).
                exit(DirectCostAppliedAccount);
        end;
    end;

    local procedure GetActualAccounts(ValueEntry: Record "Value Entry"; var ActualInventoryGL: Code[20]; var ActualOffsetGL: Code[20])
    var
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLEntry: Record "G/L Entry";
        FirstGLFound: Boolean;
    begin
        Clear(ActualInventoryGL);
        Clear(ActualOffsetGL);

        // The first related G/L entry is treated as the inventory leg, the next as the offset leg.
        GLItemLedgerRelation.SetRange("Value Entry No.", ValueEntry."Entry No.");
        if GLItemLedgerRelation.FindSet() then
            repeat
                if GLEntry.Get(GLItemLedgerRelation."G/L Entry No.") then
                    if not FirstGLFound then begin
                        ActualInventoryGL := GLEntry."G/L Account No.";
                        FirstGLFound := true;
                    end else
                        ActualOffsetGL := GLEntry."G/L Account No.";
            until GLItemLedgerRelation.Next() = 0;
    end;
}
