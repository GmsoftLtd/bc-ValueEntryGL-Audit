/// <summary>
/// Audits Value Entries by comparing expected G/L accounts (from posting groups) against the actual posted G/L accounts.
/// </summary>
report 50100 "Value Entry G/L Audit"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Value Entry G/L Audit';
    DefaultRenderingLayout = "ValueEntryAuditRDLC";

    dataset
    {
        dataitem(ValueEntry; "Value Entry")
        {
            column(ValueEntryNo; "Entry No.") { }
            column(ItemNo; "Item No.") { }
            column(DocumentNo; "Document No.") { }
            column(PostingDate; "Posting Date") { }
            column(EntryType; "Entry Type") { }
            column(ItemLedgerEntryType; "Item Ledger Entry Type") { }
            column(InventoryPostingGroup; "Inventory Posting Group") { }
            column(GenBusPostingGroup; "Gen. Bus. Posting Group") { }
            column(GenProdPostingGroup; "Gen. Prod. Posting Group") { }

            // Expected Accounts
            column(ExpectedInventoryGL; ExpectedInventoryGL) { }
            column(ExpectedOffsetGL; ExpectedOffsetGL) { }

            // Actual Accounts (from related G/L Entries)
            column(ActualInventoryGL; ActualInventoryGL) { }
            column(ActualOffsetGL; ActualOffsetGL) { }
            column(Mismatch; Mismatch) { }

            // G/L accounts from Posting Groups
            column(InventoryGLFromPostingGroup; InventoryGLFromPostingGroup) { }
            column(COGSGLFromPostingGroup; COGSGLFromPostingGroup) { }
            column(DirectCostAppliedGLFromPostingGroup; DirectCostAppliedGLFromPostingGroup) { }
            column(InventoryAdjmtGLFromPostingGroup; InventoryAdjmtGLFromPostingGroup) { }

            trigger OnAfterGetRecord()
            begin
                AuditMgt.CalculateAudit(
                    ValueEntry,
                    ExpectedInventoryGL, ExpectedOffsetGL,
                    ActualInventoryGL, ActualOffsetGL,
                    InventoryGLFromPostingGroup, COGSGLFromPostingGroup,
                    DirectCostAppliedGLFromPostingGroup, InventoryAdjmtGLFromPostingGroup,
                    Mismatch);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Group)
                {
                    field(PostingDateFilter; ValueEntry."Posting Date")
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date Filter';
                    }
                }
            }
        }
    }

    rendering
    {
        layout("ValueEntryAuditRDLC")
        {
            Type = RDLC;
            LayoutFile = './src/Reports/ValueEntryAuditReport.rdl';
            Caption = 'Value Entry G/L Audit';
            Summary = 'Tabular layout that highlights value entries whose posted G/L accounts differ from the expected accounts.';
        }
    }

    var
        AuditMgt: Codeunit "Value Entry Audit Mgt.";
        ExpectedInventoryGL: Code[20];
        ExpectedOffsetGL: Code[20];
        ActualInventoryGL: Code[20];
        ActualOffsetGL: Code[20];
        InventoryGLFromPostingGroup: Code[20];
        COGSGLFromPostingGroup: Code[20];
        DirectCostAppliedGLFromPostingGroup: Code[20];
        InventoryAdjmtGLFromPostingGroup: Code[20];
        Mismatch: Boolean;
}
