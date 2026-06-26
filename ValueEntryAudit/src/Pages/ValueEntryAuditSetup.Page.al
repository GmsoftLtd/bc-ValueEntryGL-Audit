/// <summary>
/// Setup card for the Value Entry G/L Audit: defines the audit horizon and email delivery, and lets
/// the user run the audit on demand or schedule it.
/// </summary>
page 50106 "Value Entry Audit Setup"
{
    PageType = Card;
    SourceTable = "Value Entry Audit Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Value Entry Audit Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Scope)
            {
                Caption = 'Scope';

                field("Audit Horizon"; Rec."Audit Horizon")
                {
                    ToolTip = 'Specifies how far back from today the audit scans value entries (for example, -3M). Leave blank to scan all dates.';
                }
            }
            group(Notification)
            {
                Caption = 'Email Notification';

                field("Send Email"; Rec."Send Email")
                {
                    ToolTip = 'Specifies whether an email with the audit report is sent after each run.';
                }
                field("Recipient Email"; Rec."Recipient Email")
                {
                    Enabled = Rec."Send Email";
                    ToolTip = 'Specifies the address that receives the audit report.';
                }
                field("Send Only When Mismatches"; Rec."Send Only When Mismatches")
                {
                    Enabled = Rec."Send Email";
                    ToolTip = 'Specifies that an email is sent only when the run finds at least one mismatch.';
                }
            }
            group(LastRun)
            {
                Caption = 'Last Run';

                field("Last Run At"; Rec."Last Run At")
                {
                    ToolTip = 'Specifies when the audit last ran.';
                }
                field("Last Mismatch Count"; Rec."Last Mismatch Count")
                {
                    ToolTip = 'Specifies how many mismatches the last run found.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunNow)
            {
                ApplicationArea = All;
                Caption = 'Run Audit Now';
                ToolTip = 'Runs the audit immediately over the configured horizon and sends the email when enabled.';
                Image = Start;

                trigger OnAction()
                var
                    AuditJob: Codeunit "Value Entry Audit Job";
                begin
                    AuditJob.RunAndNotify();
                    CurrPage.Update(false);
                    Message(RunCompletedMsg, Rec."Last Mismatch Count");
                end;
            }
            action(ScheduleJob)
            {
                ApplicationArea = All;
                Caption = 'Schedule Recurring Audit';
                ToolTip = 'Creates a recurring Job Queue Entry that runs the audit out-of-hours (daily at 02:00).';
                Image = Calendar;

                trigger OnAction()
                var
                    AuditJob: Codeunit "Value Entry Audit Job";
                begin
                    AuditJob.ScheduleJobQueue();
                    Message(JobScheduledMsg);
                end;
            }
            action(ShowResults)
            {
                ApplicationArea = All;
                Caption = 'Show Results';
                ToolTip = 'Opens the list of mismatches found by previous audit runs.';
                Image = ViewDetails;
                RunObject = page "Value Entry G/L Audit Results";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(RunNow_Promoted; RunNow) { }
                actionref(ScheduleJob_Promoted; ScheduleJob) { }
                actionref(ShowResults_Promoted; ShowResults) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;

    var
        RunCompletedMsg: Label 'Audit completed. %1 mismatch(es) found.', Comment = '%1 = number of mismatches';
        JobScheduledMsg: Label 'A recurring audit job has been scheduled to run daily at 02:00.';
}
