/// <summary>
/// Adds an action to the Value Entries page to run the Value Entry G/L Audit report.
/// </summary>
pageextension 50101 "ValueEntryPageExt" extends "Value Entries"
{
    actions
    {
        addlast(Processing)
        {
            action(ValueEntryAuditReport)
            {
                ApplicationArea = All;
                Caption = 'Run G/L Audit Report';
                ToolTip = 'Runs the Value Entry G/L Audit report to compare expected and actual G/L accounts.';
                Image = Report;
                trigger OnAction()
                begin
                    Report.RunModal(Report::"Value Entry G/L Audit", true, true);
                end;
            }
        }
    }
}