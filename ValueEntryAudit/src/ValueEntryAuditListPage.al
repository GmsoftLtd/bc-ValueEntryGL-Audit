/// <summary>
/// List page showing Value Entries alongside their expected and actual G/L accounts, highlighting
/// any rows where the posted accounts differ from what the posting setup expects.
/// </summary>
page 50102 "Value Entry G/L Audit List"
{
    PageType = List;
    SourceTable = "Value Entry";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Value Entry G/L Audit';
    Editable = false;
    SourceTableView = sorting("Entry No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the value entry.';
                    StyleExpr = MismatchStyleExpr;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item the value entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number the value entry was posted with.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date of the value entry.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value entry type (for example, Direct Cost or Revaluation).';
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    ToolTip = 'Specifies the item ledger entry type (for example, Sale or Purchase) that drives the expected offset account.';
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ToolTip = 'Specifies the inventory posting group used to resolve the expected inventory account.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the general business posting group used to resolve the expected offset account.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ToolTip = 'Specifies the general product posting group used to resolve the expected offset account.';
                }
                field(ExpectedInventoryGL; ExpectedInventoryGL)
                {
                    Caption = 'Expected Inventory G/L';
                    ToolTip = 'Specifies the inventory G/L account expected from the inventory posting setup.';
                    StyleExpr = MismatchStyleExpr;
                }
                field(ActualInventoryGL; ActualInventoryGL)
                {
                    Caption = 'Actual Inventory G/L';
                    ToolTip = 'Specifies the G/L account actually posted for the inventory leg.';
                    StyleExpr = MismatchStyleExpr;
                }
                field(ExpectedOffsetGL; ExpectedOffsetGL)
                {
                    Caption = 'Expected Offset G/L';
                    ToolTip = 'Specifies the offset G/L account expected from the general posting setup.';
                    StyleExpr = MismatchStyleExpr;
                }
                field(ActualOffsetGL; ActualOffsetGL)
                {
                    Caption = 'Actual Offset G/L';
                    ToolTip = 'Specifies the G/L account actually posted for the offset leg.';
                    StyleExpr = MismatchStyleExpr;
                }
                field(Mismatch; Mismatch)
                {
                    Caption = 'Mismatch';
                    ToolTip = 'Specifies whether an expected G/L account differs from the actual posted account.';
                    StyleExpr = MismatchStyleExpr;
                }
                field(InventoryGLFromPostingGroup; InventoryGLFromPostingGroup)
                {
                    Caption = 'Inventory Account (Setup)';
                    ToolTip = 'Specifies the inventory account configured on the inventory posting setup.';
                }
                field(COGSGLFromPostingGroup; COGSGLFromPostingGroup)
                {
                    Caption = 'COGS Account (Setup)';
                    ToolTip = 'Specifies the COGS account configured on the general posting setup.';
                }
                field(DirectCostAppliedGLFromPostingGroup; DirectCostAppliedGLFromPostingGroup)
                {
                    Caption = 'Direct Cost Applied Account (Setup)';
                    ToolTip = 'Specifies the direct cost applied account configured on the general posting setup.';
                }
                field(InventoryAdjmtGLFromPostingGroup; InventoryAdjmtGLFromPostingGroup)
                {
                    Caption = 'Inventory Adjmt. Account (Setup)';
                    ToolTip = 'Specifies the inventory adjustment account configured on the general posting setup.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AuditMgt.CalculateAudit(
            Rec,
            ExpectedInventoryGL, ExpectedOffsetGL,
            ActualInventoryGL, ActualOffsetGL,
            InventoryGLFromPostingGroup, COGSGLFromPostingGroup,
            DirectCostAppliedGLFromPostingGroup, InventoryAdjmtGLFromPostingGroup,
            Mismatch);

        if Mismatch then
            MismatchStyleExpr := 'Unfavorable'
        else
            MismatchStyleExpr := '';
    end;

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
        MismatchStyleExpr: Text;
        Mismatch: Boolean;
}
