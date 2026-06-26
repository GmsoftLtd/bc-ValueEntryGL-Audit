/// <summary>
/// Runs the Value Entry G/L audit over the configured horizon, stores the findings, and emails the
/// report. Designed to be scheduled out-of-hours through a Job Queue Entry.
/// </summary>
codeunit 50108 "Value Entry Audit Job"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        RunAndNotify();
    end;

    /// <summary>
    /// Executes one audit run: scans the horizon, persists mismatches, updates the setup statistics,
    /// and sends the email when configured.
    /// </summary>
    procedure RunAndNotify()
    var
        Setup: Record "Value Entry Audit Setup";
        AuditMgt: Codeunit "Value Entry Audit Mgt.";
        StartDate: Date;
        EndDate: Date;
        RunDateTime: DateTime;
        MismatchCount: Integer;
    begin
        Setup.GetSetup();
        StartDate := Setup.GetStartDate();
        EndDate := Today();
        RunDateTime := CurrentDateTime();

        MismatchCount := AuditMgt.RunAudit(StartDate, EndDate, RunDateTime);

        Setup."Last Run At" := RunDateTime;
        Setup."Last Mismatch Count" := MismatchCount;
        Setup.Modify(true);

        if ShouldSendEmail(Setup, MismatchCount) then
            SendAuditEmail(Setup, StartDate, EndDate, MismatchCount);
    end;

    local procedure ShouldSendEmail(Setup: Record "Value Entry Audit Setup"; MismatchCount: Integer): Boolean
    begin
        if not Setup."Send Email" then
            exit(false);
        if Setup."Recipient Email" = '' then
            exit(false);
        if Setup."Send Only When Mismatches" and (MismatchCount = 0) then
            exit(false);
        exit(true);
    end;

    local procedure SendAuditEmail(Setup: Record "Value Entry Audit Setup"; StartDate: Date; EndDate: Date; MismatchCount: Integer)
    var
        ValueEntry: Record "Value Entry";
        TempBlob: Codeunit "Temp Blob";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        RecRef: RecordRef;
        OutStr: OutStream;
        InStr: InStream;
        Subject: Text;
        Body: Text;
    begin
        ValueEntry.SetRange("Posting Date", StartDate, EndDate);
        RecRef.GetTable(ValueEntry);

        TempBlob.CreateOutStream(OutStr);
        Report.SaveAs(Report::"Value Entry G/L Audit", '', ReportFormat::Pdf, OutStr, RecRef);
        TempBlob.CreateInStream(InStr);

        Subject := StrSubstNo(SubjectTxt, MismatchCount);
        Body := StrSubstNo(BodyTxt, MismatchCount, Format(StartDate), Format(EndDate));

        EmailMessage.Create(Setup."Recipient Email", Subject, Body, true);
        EmailMessage.AddAttachment(AttachmentNameTxt, 'application/pdf', InStr);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    /// <summary>
    /// Creates (or refreshes) a recurring Job Queue Entry that runs this audit out-of-hours.
    /// </summary>
    procedure ScheduleJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Value Entry Audit Job");
        JobQueueEntry.DeleteAll(true);

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Value Entry Audit Job";
        JobQueueEntry.Description := CopyStr(JobDescriptionTxt, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."Run on Mondays" := true;
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := true;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Starting Time" := 020000T;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    var
        SubjectTxt: Label 'Value Entry G/L Audit - %1 mismatch(es) found', Comment = '%1 = number of mismatches';
        BodyTxt: Label 'The Value Entry G/L Audit found %1 mismatch(es) for posting dates %2 to %3. See the attached report for details.', Comment = '%1 = mismatch count, %2 = start date, %3 = end date';
        AttachmentNameTxt: Label 'Value Entry G_L Audit.pdf';
        JobDescriptionTxt: Label 'Value Entry G/L Audit';
}
