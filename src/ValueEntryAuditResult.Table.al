/// <summary>
/// Stores the mismatches found by each audit run so findings have history and can be reviewed later.
/// </summary>
table 50105 "Value Entry Audit Result"
{
    Caption = 'Value Entry Audit Result';
    DataClassification = CustomerContent;
    DrillDownPageId = "Value Entry G/L Audit Results";
    LookupPageId = "Value Entry G/L Audit Results";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Run Date/Time"; DateTime)
        {
            Caption = 'Run Date/Time';
        }
        field(20; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            TableRelation = "Value Entry"."Entry No.";
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(40; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(50; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(60; "Expected Inventory G/L"; Code[20])
        {
            Caption = 'Expected Inventory G/L';
            TableRelation = "G/L Account"."No.";
        }
        field(61; "Actual Inventory G/L"; Code[20])
        {
            Caption = 'Actual Inventory G/L';
            TableRelation = "G/L Account"."No.";
        }
        field(70; "Expected Offset G/L"; Code[20])
        {
            Caption = 'Expected Offset G/L';
            TableRelation = "G/L Account"."No.";
        }
        field(71; "Actual Offset G/L"; Code[20])
        {
            Caption = 'Actual Offset G/L';
            TableRelation = "G/L Account"."No.";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Run; "Run Date/Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Value Entry No.", "Item No.", "Posting Date") { }
    }
}
