Table 50067 "Posted Travel Request Header"
{

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Department; Code[20])
        {
            TableRelation = "Dimension Value".Code where("Global Dimension No." = filter(1));
        }
        field(3; "Employee No."; Code[20])
        {
            TableRelation = Employee;
        }
        field(4; "Employee Name"; Text[100])
        {
        }
        field(5; "Raised Date"; Date)
        {
        }
        field(6; "Raised By"; Code[30])
        {
        }
        field(7; "Approval Status"; Option)
        {
            OptionCaption = 'Open,Pending Approval,Approved,Disapproved,Canceled';
            OptionMembers = Open,"Pending Approval",Approved,Disapproved,Canceled;
        }
        field(8; "No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(9; "Currency Code"; Code[10])
        {
            TableRelation = Currency where(Code = const('USD'));
        }
        field(10; Location; Code[10])
        {
            TableRelation = Location;
        }
        field(11; "HR Approval Status"; Option)
        {
            OptionCaption = 'Open,Pending Approval,Approved,Disapproved,Canceled';
            OptionMembers = Open,"Pending Approval",Approved,Disapproved,Canceled;
        }
        field(12; "Approval By"; Code[30])
        {
            TableRelation = "User Setup";
        }
        field(13; "Employee Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Travel From Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Travel To Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "No. of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Travel Purpose"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Travel From"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Travel To"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;
        }
        field(21; "Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Travel Mode"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Taxi,Flight,Bus,Train,Self';
            OptionMembers = " ",Taxi,Flight,Bus,Train,Self;
        }
        field(23; Amount; Decimal)
        {
            CalcFormula = sum ("Posted Travel Request Line"."Total Amount" where("Document No." = field("No.")));
            FieldClass = FlowField;
        }
        field(24; "Accomodation Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Company,Self';
            OptionMembers = Company,Self;
        }
        field(25; "HR Approval By"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(26; Approver; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Approval Matrix"."Approver ID" where("Travel Approver" = const(true),
                                                                   Branch = field(Department));
        }
        field(27; "HR Approver"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Approval Matrix"."Approver ID" where("Travel HR Approver" = const(true),
                                                                   Branch = field(Department));
        }
        field(28; "Approval Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "HR Approval Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Approval Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(31; "HR Admin User"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(32; "HR Approval Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

