/// <summary>
/// Tests for the Value Entry G/L Audit calculation logic in codeunit "Value Entry Audit Mgt.".
/// </summary>
codeunit 50150 "Value Entry Audit Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        InvAccTok: Label '10000', Locked = true;
        COGSAccTok: Label '20000', Locked = true;
        DirectCostAccTok: Label '30000', Locked = true;
        InvAdjmtAccTok: Label '40000', Locked = true;
        InvGrpTok: Label 'VEATEST', Locked = true;
        BusGrpTok: Label 'VEATBUS', Locked = true;
        ProdGrpTok: Label 'VEATPROD', Locked = true;

    [Test]
    procedure ExpectedAccountsResolvedForPurchase()
    var
        ValueEntry: Record "Value Entry";
        AuditMgt: Codeunit "Value Entry Audit Mgt.";
        ExpInv: Code[20];
        ExpOff: Code[20];
        ActInv: Code[20];
        ActOff: Code[20];
        InvSetupAcc: Code[20];
        COGS: Code[20];
        DCA: Code[20];
        InvAdj: Code[20];
        Mismatch: Boolean;
    begin
        // [GIVEN] Posting setup and a purchase value entry with no related G/L entries
        SetupPostingData();
        CreateValueEntry(ValueEntry, ValueEntry."Item Ledger Entry Type"::Purchase);

        // [WHEN] Calculating the audit
        AuditMgt.CalculateAudit(ValueEntry, ExpInv, ExpOff, ActInv, ActOff, InvSetupAcc, COGS, DCA, InvAdj, Mismatch);

        // [THEN] Expected accounts come from the setup; actual accounts are blank; mismatch is flagged
        LibraryAssert.AreEqual(InvAccTok, ExpInv, 'Expected inventory account should come from inventory posting setup');
        LibraryAssert.AreEqual(DirectCostAccTok, ExpOff, 'Expected offset for a purchase should be the Direct Cost Applied account');
        LibraryAssert.AreEqual('', ActInv, 'Actual inventory should be blank without related G/L entries');
        LibraryAssert.AreEqual('', ActOff, 'Actual offset should be blank without related G/L entries');
        LibraryAssert.IsTrue(Mismatch, 'A mismatch is expected when the expected accounts are not posted');
    end;

    [Test]
    procedure ExpectedOffsetIsCOGSForSale()
    var
        ValueEntry: Record "Value Entry";
        AuditMgt: Codeunit "Value Entry Audit Mgt.";
        ExpInv: Code[20];
        ExpOff: Code[20];
        ActInv: Code[20];
        ActOff: Code[20];
        InvSetupAcc: Code[20];
        COGS: Code[20];
        DCA: Code[20];
        InvAdj: Code[20];
        Mismatch: Boolean;
    begin
        // [GIVEN] Posting setup and a sale value entry
        SetupPostingData();
        CreateValueEntry(ValueEntry, ValueEntry."Item Ledger Entry Type"::Sale);

        // [WHEN] Calculating the audit
        AuditMgt.CalculateAudit(ValueEntry, ExpInv, ExpOff, ActInv, ActOff, InvSetupAcc, COGS, DCA, InvAdj, Mismatch);

        // [THEN] The expected offset for a sale is the COGS account
        LibraryAssert.AreEqual(COGSAccTok, ExpOff, 'Expected offset for a sale should be the COGS account');
    end;

    [Test]
    procedure NoMismatchWhenActualMatchesExpected()
    var
        ValueEntry: Record "Value Entry";
        AuditMgt: Codeunit "Value Entry Audit Mgt.";
        ExpInv: Code[20];
        ExpOff: Code[20];
        ActInv: Code[20];
        ActOff: Code[20];
        InvSetupAcc: Code[20];
        COGS: Code[20];
        DCA: Code[20];
        InvAdj: Code[20];
        Mismatch: Boolean;
    begin
        // [GIVEN] A purchase value entry whose related G/L entries match the expected accounts
        SetupPostingData();
        CreateValueEntry(ValueEntry, ValueEntry."Item Ledger Entry Type"::Purchase);
        CreateGLRelation(ValueEntry."Entry No.", InvAccTok);       // inventory leg (first)
        CreateGLRelation(ValueEntry."Entry No.", DirectCostAccTok); // offset leg (second)

        // [WHEN] Calculating the audit
        AuditMgt.CalculateAudit(ValueEntry, ExpInv, ExpOff, ActInv, ActOff, InvSetupAcc, COGS, DCA, InvAdj, Mismatch);

        // [THEN] Actual accounts match expected and no mismatch is flagged
        LibraryAssert.AreEqual(InvAccTok, ActInv, 'Actual inventory account should match the first related G/L entry');
        LibraryAssert.AreEqual(DirectCostAccTok, ActOff, 'Actual offset account should match the second related G/L entry');
        LibraryAssert.IsFalse(Mismatch, 'No mismatch expected when posted accounts equal the expected accounts');
    end;

    local procedure SetupPostingData()
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not InventoryPostingSetup.Get('', InvGrpTok) then begin
            InventoryPostingSetup.Init();
            InventoryPostingSetup."Location Code" := '';
            InventoryPostingSetup."Invt. Posting Group Code" := InvGrpTok;
            InventoryPostingSetup.Insert();
        end;
        InventoryPostingSetup."Inventory Account" := InvAccTok;
        InventoryPostingSetup.Modify();

        if not GeneralPostingSetup.Get(BusGrpTok, ProdGrpTok) then begin
            GeneralPostingSetup.Init();
            GeneralPostingSetup."Gen. Bus. Posting Group" := BusGrpTok;
            GeneralPostingSetup."Gen. Prod. Posting Group" := ProdGrpTok;
            GeneralPostingSetup.Insert();
        end;
        GeneralPostingSetup."COGS Account" := COGSAccTok;
        GeneralPostingSetup."Direct Cost Applied Account" := DirectCostAccTok;
        GeneralPostingSetup."Inventory Adjmt. Account" := InvAdjmtAccTok;
        GeneralPostingSetup.Modify();
    end;

    local procedure CreateValueEntry(var ValueEntry: Record "Value Entry"; EntryType: Enum "Item Ledger Entry Type")
    var
        LastValueEntry: Record "Value Entry";
        NextEntryNo: Integer;
    begin
        if LastValueEntry.FindLast() then
            NextEntryNo := LastValueEntry."Entry No." + 1
        else
            NextEntryNo := 1;

        ValueEntry.Init();
        ValueEntry."Entry No." := NextEntryNo;
        ValueEntry."Item Ledger Entry Type" := EntryType;
        ValueEntry."Location Code" := '';
        ValueEntry."Inventory Posting Group" := InvGrpTok;
        ValueEntry."Gen. Bus. Posting Group" := BusGrpTok;
        ValueEntry."Gen. Prod. Posting Group" := ProdGrpTok;
        ValueEntry.Insert(false);
    end;

    local procedure CreateGLRelation(ValueEntryNo: Integer; GLAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        LastGLEntry: Record "G/L Entry";
        NextGLEntryNo: Integer;
    begin
        if LastGLEntry.FindLast() then
            NextGLEntryNo := LastGLEntry."Entry No." + 1
        else
            NextGLEntryNo := 1;

        GLEntry.Init();
        GLEntry."Entry No." := NextGLEntryNo;
        GLEntry."G/L Account No." := GLAccountNo;
        GLEntry.Insert(false);

        GLItemLedgerRelation.Init();
        GLItemLedgerRelation."G/L Entry No." := NextGLEntryNo;
        GLItemLedgerRelation."Item Ledger Entry No." := NextGLEntryNo;
        GLItemLedgerRelation."Value Entry No." := ValueEntryNo;
        GLItemLedgerRelation.Insert(false);
    end;
}
