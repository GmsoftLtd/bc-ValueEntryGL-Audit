/// <summary>
/// History of mismatches recorded by audit runs.
/// </summary>
page 50107 "Value Entry G/L Audit Results"
{
    PageType = List;
    SourceTable = "Value Entry Audit Result";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Value Entry G/L Audit Results';
    Editable = false;
    SourceTableView = sorting("Run Date/Time") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Run Date/Time"; Rec."Run Date/Time")
                {
                    ToolTip = 'Specifies when the audit run that recorded this mismatch took place.';
                }
                field("Value Entry No."; Rec."Value Entry No.")
                {
                    ToolTip = 'Specifies the value entry that was flagged.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item the flagged value entry belongs to.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date of the flagged value entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number of the flagged value entry.';
                }
                field("Expected Inventory G/L"; Rec."Expected Inventory G/L")
                {
                    ToolTip = 'Specifies the inventory G/L account expected from the inventory posting setup.';
                }
                field("Actual Inventory G/L"; Rec."Actual Inventory G/L")
                {
                    ToolTip = 'Specifies the G/L account actually posted for the inventory leg.';
                }
                field("Expected Offset G/L"; Rec."Expected Offset G/L")
                {
                    ToolTip = 'Specifies the offset G/L account expected from the general posting setup.';
                }
                field("Actual Offset G/L"; Rec."Actual Offset G/L")
                {
                    ToolTip = 'Specifies the G/L account actually posted for the offset leg.';
                }
            }
        }
    }
}
