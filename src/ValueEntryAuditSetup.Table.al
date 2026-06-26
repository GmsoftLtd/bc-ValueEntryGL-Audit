/// <summary>
/// Singleton setup that controls how far back the audit looks and how findings are emailed.
/// </summary>
table 50104 "Value Entry Audit Setup"
{
    Caption = 'Value Entry Audit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Audit Horizon"; DateFormula)
        {
            Caption = 'Audit Horizon';
            ToolTip = 'Specifies how far back from today the audit scans value entries (for example, -3M). Leave blank to scan all dates.';
        }
        field(20; "Send Email"; Boolean)
        {
            Caption = 'Send Email';
            ToolTip = 'Specifies whether an email with the audit report is sent after each run.';
        }
        field(21; "Recipient Email"; Text[250])
        {
            Caption = 'Recipient Email';
            ExtendedDatatype = EMail;
            ToolTip = 'Specifies the address that receives the audit report.';

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Recipient Email" <> '' then
                    MailManagement.CheckValidEmailAddresses("Recipient Email");
            end;
        }
        field(22; "Send Only When Mismatches"; Boolean)
        {
            Caption = 'Send Only When Mismatches Found';
            InitValue = true;
            ToolTip = 'Specifies that an email is sent only when the run finds at least one mismatch.';
        }
        field(30; "Last Run At"; DateTime)
        {
            Caption = 'Last Run At';
            Editable = false;
            ToolTip = 'Specifies when the audit last ran.';
        }
        field(31; "Last Mismatch Count"; Integer)
        {
            Caption = 'Last Mismatch Count';
            Editable = false;
            ToolTip = 'Specifies how many mismatches the last run found.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Returns the single setup record, creating it on first use.
    /// </summary>
    procedure GetSetup()
    begin
        Reset();
        if not Get('') then begin
            Init();
            "Primary Key" := '';
            Insert(true);
        end;
    end;

    /// <summary>
    /// Resolves the first posting date to include in the audit.
    /// </summary>
    /// <returns>The earliest posting date to audit, or 0D (no lower bound) when no horizon is set.</returns>
    procedure GetStartDate(): Date
    begin
        if Format("Audit Horizon") = '' then
            exit(0D);
        exit(CalcDate("Audit Horizon", Today()));
    end;
}
