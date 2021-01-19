Page 50072 "Business Cards Request"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter("Business Card"));

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; "No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Branch; Branch)
                {
                    ApplicationArea = Basic;
                }
                field(Department; Department)
                {
                    ApplicationArea = Basic;
                }
                field(EmployeeNo; "Employee No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(EmployeeName; "Employee Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(RaisedDate; "Raised Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(RaisedBy; "Raised By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Line Manager"; Approver)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(ApprovalStatus; "Approval Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Location; Location)
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                group(BusinessCardDetails)
                {
                    Caption = 'Business Card Details';
                    field(Name; Name)
                    {
                        ApplicationArea = Basic;
                    }
                    field(Title; Title)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Title';
                    }
                    field(PhysicalLocation; "Physical Location")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Physical Location';
                    }
                    field(Address; Address)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Address';
                    }
                    field(CellNumber; "Cell Number")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Cell Number';
                    }
                    field(TelephoneNumber; "Telephone Number")
                    {
                        ApplicationArea = Basic;
                        //DecimalPlaces =  0  0;
                        Editable = false;
                    }
                    field(DirectTelephone; "Direct Telephone")
                    {
                        ApplicationArea = Basic;

                        trigger OnValidate()
                        begin
                            InsertTravelLine;
                        end;
                    }
                    field(FaxNumber; "Fax Number")
                    {
                        ApplicationArea = Basic;
                    }
                    field(QtyRequested; "Qty Requested")
                    {
                        ApplicationArea = Basic;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            "Travel Purpose" := UpperCase("Travel Purpose");
                        end;
                    }
                    field(EmailAddress; "Email Address")
                    {
                        ApplicationArea = Basic;
                    }
                }
            }
            group(Control38)
            {
                Caption = 'Approvals';
                field(ApprovalBy; "Approval By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(ApprovalDate; "Approval Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Approvals)
            {
                Caption = 'Approvals';
                action(SubmitforApproval)
                {
                    ApplicationArea = Basic;
                    Caption = 'Submit for Approval';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        TestField(Name);
                        TestField(Title);
                        TestField("Physical Location");
                        TestField(Address);
                        TestField("Cell Number");
                        TestField("Telephone Number");
                        TestField("Direct Telephone");
                        TestField("Fax Number");
                        TestField("Qty Requested");
                        TestField("Email Address");

                        TestField("Approval Status", "approval status"::Open);
                        TravelMgmt.SubmitBusinesscardForApproval(Rec);
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //Cancel Approval Request and status
                        if Confirm(Text001) then begin
                            "Approval Status" := "approval status"::Open;
                            Modify;
                        end;

                        //RO.UTL.09.10.2019
                        //To Pick SUBSTITUTE APPROVER IF APPROVER HAS DELEGATED AND CANCEL APPROVAL
                        "Approval By" := '';
                        "Approval Date" := 0D;
                        UserSetup.Get(UserId);
                        Branch := UserSetup.Branch;
                        Department := UserSetup."Department Code";
                        Approver := '';
                        if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then begin
                            Approver := UserSetup.Substitute
                        end else
                            Approver := UserSetup."Approver ID";

                        //END
                    end;
                }
                action(Print)
                {
                    ApplicationArea = Basic;
                    Caption = 'Print Requisition';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        travelheader: Record "Travel Request Header";
                        RptReqn: Report "BussCard Request";
                        saveFile: Boolean;
                        BsRequestNo: Text;
                    begin

                        //TESTFIELD(Status,Status::Released);
                        travelheader.SETRANGE(Type, travelheader.Type::"Business Card");
                        travelheader.SETRANGE("No.", "No.");
                        RptReqn.SETTABLEVIEW(travelheader);
                        RptReqn.RUNMODAL;


                        /*                         saveFile:=true;
                                                travelheader.SetRange("No.",Rec."No.");
                                                RptReqn.SetTableview(travelheader);
                                                BsRequestNo:='Business Card Request_'+DelChr(Rec."No.",'=','/')+'.pdf';
                                                FileName:='\\172.16.60.3\GAB-Users\Procurement-Administration\ERP System\ERP Documents To Print\'+ BsRequestNo;
                                                saveFile:=RptReqn.SaveAsPdf(FileName);
                                                Message(BsRequestNo); */

                    end;
                }
            }
            action(Archive)
            {
                ApplicationArea = Basic;
                Image = Archive;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = false;

                trigger OnAction()
                begin
                    //CALCFIELDS("Completely Received");
                    //TESTFIELD(Status,Status::Dissaproved);
                    if Confirm(Text002) then begin
                        Archived := true;
                        Modify
                    end;
                    Message('The Document Has been succesfully archived');
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Travelheader: Record "Travel Request Header";
        Telno: Text;
    begin
        if UserSetup.Get(UserId) then;

        if UserSetup."Employee No." <> '' then
            Employee.Get(UserSetup."Employee No.");

        //UserSetup.CALCFIELDS(Location);
        //Location := UserSetup.Location;
        //Department := UserSetup.Department;
        Validate("Employee No.", UserSetup."Employee No.");
        "Employee Name" := Employee.FullName;

        CompanyInfo.Get;
        CompanyInfo.TestField("Phone No.");
        if CompanyInfo.FindFirst then
            "Telephone Number" := CompanyInfo."Phone No.";

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        openitems: Boolean;
    begin
        Travelheader.SetCurrentkey("No.");
        Travelheader.SetRange(Type, Travelheader.Type::"Business Card");
        Travelheader.SetRange("Approval Status", Travelheader."approval status"::Open);
        Travelheader.SetRange("Raised By", UserId);
        if Travelheader.FindFirst then
            openitems := true;

        if openitems = true then Error('Kindly utilize the open record on the page');
    end;

    trigger OnOpenPage()
    begin
        //SETFILTER("Raised By", USERID);
    end;

    var
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        HRSetup: Record "Human Resources Setup";
        LocationCODE: Code[10];
        Loc: Record Location;
        TravelLine: Record "Travel Request Line";
        TravelMgmt: Codeunit "Travel Management";
        Text004: label 'Approval Status must be Open or "Pending Approval" for the travel request to be canceled';
        CompanyInfo: Record "Company Information";
        Travelheader: Record "Travel Request Header";
        Text001: label 'Do you want to recall the approval request';
        FileName: Text;
        Text002: label 'Do you want to Archive the approval request?';

    local procedure InsertTravelLine()
    begin
    end;
}

