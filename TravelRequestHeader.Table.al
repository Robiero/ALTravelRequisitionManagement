Table 50065 "Travel Request Header"
{

    fields
    {
        field(1; "No."; Code[20])
        {

            trigger OnValidate()
            begin

                if Type = Type::Travel then begin
                    if "No." = '' then begin
                        HRSetup.Get;
                        NoSeriesMgt.TestManual(HRSetup."Travel Requisition Nos.");
                        "No. Series" := '';
                    end
                end else
                    if Type = Type::"Business Card" then begin

                        if "No." = '' then begin
                            HRSetup.Get;
                            NoSeriesMgt.TestManual(HRSetup."Business Cards Nos");
                            "No. Series" := '';
                        end
                    end else
                        if Type = Type::Stamp then begin
                            if "No." = '' then begin
                                HRSetup.Get;
                                NoSeriesMgt.TestManual(HRSetup."Stamp Nos");
                                "No. Series" := '';
                            end
                        end;
            end;
        }
        field(2; Department; Code[50])
        {
            TableRelation = "Dimension Value".Code where("Global Dimension No." = filter(2));

            trigger OnValidate()
            begin
                //"HRBP Approver" := '';
                //IF Branch='1' THEN BEGIN
                // UserSetup.SETCURRENTKEY("User ID","Department Code");
                //  UserSetup.SETRANGE("Department Code",Department);
                //  UserSetup.SETRANGE("User ID", "Raised By");
                //    IF UserSetup.FIND('-') THEN BEGIN
                //    "HRBP Approver":=UserSetup."Dept HRBP";
                //      //MODIFY;
                //    END;
                //    END;
                //
                //
                // IF Branch<>'1' THEN BEGIN
                //  UserSetup.SETCURRENTKEY("User ID","Department Code");
                //  UserSetup.SETRANGE(Branch,Branch);
                //   UserSetup.SETRANGE("User ID", "Raised By");
                //  IF UserSetup.FINDFIRST THEN BEGIN
                //    "HRBP Approver":=UserSetup."Dept HRBP";
                //    END;
                //    END;
            end;
        }
        field(3; "Employee No."; Code[20])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.") then
                    "Employee Name" := Employee.FullName;
                "Employee Grade" := Employee."Travel Grade";
            end;
        }
        field(4; "Employee Name"; Text[100])
        {
        }
        field(5; "Raised Date"; Date)
        {

            trigger OnValidate()
            begin
                TestField("Approval Status", "approval status"::Open);//RO.08.2019
            end;
        }
        field(6; "Raised By"; Code[30])
        {
        }
        field(7; "Approval Status"; Option)
        {
            OptionCaption = 'Open,Pending Approval,Approved,Disapproved,Canceled,Pending HOD';
            OptionMembers = Open,"Pending Approval",Approved,Disapproved,Canceled,"Pending HOD";
        }
        field(8; "No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(9; "Currency Code"; Code[10])
        {
            TableRelation = Currency where(Code = const('USD'));

            trigger OnValidate()
            begin
                TravelLine.Reset;
                TravelLine.SetRange("Document No.", "No.");
                if TravelLine.FindFirst then
                    if TravelLine."Currency Code" <> "Currency Code" then
                        Error('You are not allowed to change the currency after filling in the amount field');
            end;
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

            trigger OnValidate()
            begin
                TestField("Approval Status", "approval status"::Open);//RO.08.2019
                if "Travel To Date" <= "Travel From Date" then
                    Error('Please select a date that is greater than the Travel From Date');

                "No. of Days" := "Travel To Date" - "Travel From Date";
            end;
        }
        field(16; "No. of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Travel Purpose"; Text[250])
        {
            Caption = 'Travel purpose Comments';
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
        field(20; "Accomodation Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if Vendor.Get("Accomodation Vendor No.") then
                    "Accomodation Vendor Name" := Vendor.Name;
            end;
        }
        field(21; "Accomodation Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Travel Mode"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Taxi,Flight,Bus,Train,Self,Company';
            OptionMembers = " ",Taxi,Flight,Bus,Train,Self,Company;
        }
        field(23; Amount; Decimal)
        {
            CalcFormula = sum ("Travel Request Line"."Total Amount" where("Document No." = field("No.")));
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
            TableRelation = "Approval Matrix"."Approver ID" where("Travel Approver" = const(true));
        }
        field(27; "HR Manager Approver"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Approval Matrix"."Approver ID" where("Travel HR Approver" = const(true));
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
        field(31; "HRBP Approver"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(32; "HR Approval Remarks"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(35; Branch; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = filter(1));
        }
        field(40; "Travel Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if Vendor.Get("Accomodation Vendor No.") then
                    "Accomodation Vendor Name" := Vendor.Name;
            end;
        }
        field(41; "Travel Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(42; Title; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(43; "Physical Location"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(44; Address; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(45; "Cell Number"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Telephone Number"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //"Telephone Number":=companyinfo."Phone No."
            end;
        }
        field(47; "Direct Telephone"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Fax Number"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Qty Requested"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Travel,Business Card,Stamp';
            OptionMembers = " ",Travel,"Business Card",Stamp;
        }
        field(51; "Proc Manager"; Code[50])
        {
            Caption = 'HOD Approval';
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(52; "Stamp Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Teller Stamp,Posted Stamp,Received Stamp,Certified Copy,Signature verified,Bank crossing,Cancelled,For or on Behalf of Gulf,Signature witnessed,Office central vault,Deliver to the order of,MD''s office,Acknowledgement copy,Swift generated stamp,To be processed the following day,Advocate,Commissioner of oath,EFT Confirmation,Cash officer,Ink Cartridge,By Registered Post';
            OptionMembers = " ","Teller Stamp","Posted Stamp","Received Stamp","Certified Copy","Signature verified","Bank crossing",Cancelled,"For or on Behalf of Gulf","Signature witnessed","Office central vault","Deliver to the order of","MD's office","Acknowledgement copy","Swift generated stamp","To be processed the following day",Advocate,"Commissioner of oath","EFT Confirmation","Cash officer","Ink Cartridge","By Registered Post";
        }
        field(53; Justification; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Line App Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "HRBP App Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "HR Mgr App Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Submit Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(58; "HR Submit Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Email Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Name; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Proc Manager Approval"; Code[30])
        {
            Caption = 'HOD Approval';
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(62; "Proc Manager Approval Date"; Date)
        {
            Caption = 'HOD Approval';
            DataClassification = ToBeClassified;
        }
        field(63; "Travel Purpose Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Audit, Risk assessment, Branch visit, Client visit, Training, Branch construction, Other ';
            OptionMembers = " ",Audit," Risk assessment"," Branch visit"," Client visit"," Training"," Branch construction"," Other ";
        }
        field(64; "Stamp Types"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Stamp Listing".Code;

            trigger OnValidate()
            begin
                if STampTypeName.Get("Stamp Types") then
                    "Stamp Name" := STampTypeName.Name;
            end;
        }
        field(65; "Stamp Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(66; Archived; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteTravelLines;
        if "Approval Status" = "approval status"::"Pending Approval" then Error('You cannot insert on a Document with status pending');
    end;

    trigger OnInsert()
    begin
        if Type = Type::Travel then begin
            if "No." = '' then begin
                HRSetup.Get;
                HRSetup.TestField("Travel Requisition Nos.");
                NoSeriesMgt.InitSeries(HRSetup."Travel Requisition Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            end
        end else
            if Type = Type::"Business Card" then begin

                if "No." = '' then begin
                    HRSetup.Get;
                    HRSetup.TestField("Business Cards Nos");
                    NoSeriesMgt.InitSeries(HRSetup."Business Cards Nos", xRec."No. Series", 0D, "No.", "No. Series");
                end
            end else
                if Type = Type::Stamp then begin
                    if "No." = '' then begin
                        HRSetup.Get;
                        HRSetup.TestField("Stamp Nos");
                        NoSeriesMgt.InitSeries(HRSetup."Stamp Nos", xRec."No. Series", 0D, "No.", "No. Series");
                    end
                end;

        "Raised Date" := Today;
        "Raised By" := UserId;


        UserSetup.Get(UserId);
        UserSetup.TestField("Full Name");
        UserSetup.TestField("Department Code");
        //"Request-By Name":= UserSetup."Full Name";
        Branch := UserSetup.Branch;
        Department := UserSetup."Department Code";
        //RO.09.10.2019 BEGIN
        if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then begin
            Approver := UserSetup.Substitute
        end else
            Approver := UserSetup."Approver ID";
        //END
        //RO.10.09.2019 BEGIN
        if Type = Type::Stamp then begin
            UserSetup.SetRange("Overall HOD Branch", true);
            if UserSetup.FindFirst then begin
                if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                    "Proc Manager" := UserSetup.Substitute
                else
                    "Proc Manager" := UserSetup."User ID";
            end;
        end;
        //END
        //RO.09.10.2019 BEGIN
        if Type = Type::Travel then begin
            UserSetup.TestField("Dept HRBP");
            UserSetup.Reset;
            UserSetup.SetRange("User ID", UserId);
            if UserSetup.Find('-') then begin
                if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                    "HRBP Approver" := UserSetup.Substitute
                else
                    "HRBP Approver" := UserSetup."Dept HRBP";

                UserSetup.Reset;
                UserSetup.SetRange("HR Manager", true);
                if UserSetup.Find('-') then begin
                    if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                        "HR Manager Approver" := UserSetup.Substitute
                    else
                        "HR Manager Approver" := UserSetup."User ID";


                    UserSetup.SetCurrentkey("User ID", "HR Administrator");
                    UserSetup.SetRange("HR Administrator", true);
                    //IF UserSetup.FINDFIRST THEN
                    // "HRBP Approver":=UserSetup."User ID";

                    //IF UserSetup.GET("HRBP Approver") THEN
                    // "HR Manager Approver":=UserSetup."Approver ID";
                end else
                    if Type = Type::"Business Card" then begin
                        UserSetup.SetCurrentkey("User ID", "HR Administrator");
                        UserSetup.SetRange("HR Administrator", true);
                        if UserSetup.FindFirst then begin
                            if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                                "HRBP Approver" := UserSetup.Substitute
                            else
                                "HRBP Approver" := UserSetup."User ID";

                        end;
                    end;
            end;
        end;

        //END

        if "Approval Status" = "approval status"::"Pending Approval" then Error('You cannot insert on a Document with status pending');
    end;

    trigger OnModify()
    begin
        if "Approval Status" = "approval status"::"Pending Approval" then Error('You cannot insert on a Document with status pending');
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        HRSetup: Record "Human Resources Setup";
        TravelHeader: Record "Travel Request Header";
        TravelLine: Record "Travel Request Line";
        Vendor: Record Vendor;
        companyinfo: Record "Company Information";
        EditFields: Boolean;
        STampTypeName: Record "Stamp Listing";

    procedure AssistEdit(TravelRequisitionHeader: Record "Travel Request Header"): Boolean
    begin
        with TravelHeader do begin
            TravelHeader := Rec;
            HRSetup.Get;
            if Type = Type::Travel then begin
                HRSetup.TestField("Travel Requisition Nos.");
                if NoSeriesMgt.SelectSeries(HRSetup."Travel Requisition Nos.", TravelRequisitionHeader."No. Series", "No. Series") then begin
                    HRSetup.Get;
                    HRSetup.TestField("Travel Requisition Nos.");
                    NoSeriesMgt.SetSeries("No.");
                    Rec := TravelHeader;
                    exit(true);
                end
            end else
                if Type = Type::"Business Card" then begin
                    HRSetup.TestField("Business Cards Nos");
                    if NoSeriesMgt.SelectSeries(HRSetup."Business Cards Nos", TravelRequisitionHeader."No. Series", "No. Series") then begin
                        HRSetup.Get;
                        HRSetup.TestField("Business Cards Nos");
                        NoSeriesMgt.SetSeries("No.");
                        Rec := TravelHeader;
                        exit(true);
                    end
                end else
                    if Type = Type::Stamp then begin
                        HRSetup.TestField("Stamp Nos");
                        if NoSeriesMgt.SelectSeries(HRSetup."Stamp Nos", TravelRequisitionHeader."No. Series", "No. Series") then begin
                            HRSetup.Get;
                            HRSetup.TestField("Stamp Nos");
                            NoSeriesMgt.SetSeries("No.");
                            Rec := TravelHeader;
                            exit(true);
                        end
                    end;

        end;
    end;

    procedure DeleteTravelLines()
    begin
        TravelLine.Reset;
        TravelLine.SetCurrentkey("Document No.");
        TravelLine.SetRange("Document No.", "No.");
        if TravelLine.FindSet then
            TravelLine.DeleteAll;
    end;
}

