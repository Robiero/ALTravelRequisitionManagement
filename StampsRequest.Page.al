Page 50076 "Stamps Request"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter(Stamp));

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
                    Editable = false;
                }
                field(Department; Department)
                {
                    ApplicationArea = Basic;
                    Editable = false;
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
                field(HeadofDepartment; "Proc Manager")
                {
                    ApplicationArea = Basic;
                    Caption = 'Head of Department';
                    Editable = false;
                }
                field(ApprovalStatus; "Approval Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if "Approval Status" = "approval status"::Open then
                            EditFields := true else
                            EditFields := false;
                    end;
                }
                field(Location; Location)
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                group(StampDetails)
                {
                    Caption = 'Stamp Details';
                    field(StampTypes; "Stamp Types")
                    {
                        ApplicationArea = Basic;
                    }
                    field(StampName; "Stamp Name")
                    {
                        ApplicationArea = Basic;
                    }
                    field(QtyRequested; "Qty Requested")
                    {
                        ApplicationArea = Basic;
                        Editable = EditFields;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            "Travel Purpose" := UpperCase("Travel Purpose");
                        end;
                    }
                    field(Justification; Justification)
                    {
                        ApplicationArea = Basic;
                        Editable = EditFields;
                        MultiLine = true;
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
                field(HeadofDepartmentApproval; "Proc Manager Approval")
                {
                    ApplicationArea = Basic;
                    Caption = 'Head of Department Approval';
                    Editable = false;
                }
                field(HeadofDepartmentApprovalDate; "Proc Manager Approval Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Head of Department Approval Date';
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


                        TestField("Approval Status", "approval status"::Open);
                        //TravelMgmt.SubmitBusinesscardForApproval(Rec);
                        TravelMgmt.SubmitStampforapproval(Rec);
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
                        //RO.09.10.2019 BEGIN
                        //CANCEL APPROVAL AND PICK SUBSTITUTE IF APPROVER HAS DELEGATED
                        "Approval By" := '';
                        "Approval Date" := 0D;
                        "Proc Manager Approval" := '';
                        "Proc Manager Approval Date" := 0D;

                        UserSetup.Get(UserId);
                        Branch := UserSetup.Branch;
                        Department := UserSetup."Department Code";

                        Approver := '';
                        if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then begin
                            Approver := UserSetup.Substitute
                        end else
                            Approver := UserSetup."Approver ID";

                        "Proc Manager" := '';
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
                        RptReqn: Report "Stamp Request";
                        saveFile: Boolean;
                        StampRequestNo: Text;
                    begin
                        TestField("Approval Status", "approval status"::Approved);

                        travelheader.SetRange(Type, travelheader.Type::Stamp);
                        travelheader.SetRange("No.", "No.");
                        RptReqn.SetTableview(travelheader);
                        RptReqn.RunModal;


                        /* //RO.09.09.2019 BEGIN
                        saveFile := true;
                        travelheader.SetRange("No.", Rec."No.");
                        RptReqn.SetTableview(travelheader);
                        StampRequestNo := 'Stamp Request_' + Rec."No." + '.pdf';
                        FileName := '\\172.16.60.3\GAB-Users\Procurement-Administration\ERP System\ERP Documents To Print\Docs To Print - Stamp Requisitions\' + StampRequestNo;
                        saveFile := RptReqn.SaveAsPdf(FileName);
                        Message(StampRequestNo);
                        //END */
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
    begin
        if UserSetup.Get(UserId) then;

        if UserSetup."Employee No." <> '' then
            Employee.Get(UserSetup."Employee No.");

        //UserSetup.CALCFIELDS(Location);
        //Location := UserSetup.Location;
        //Department := UserSetup.Department;
        Validate("Employee No.", UserSetup."Employee No.");
        "Employee Name" := Employee.FullName;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        openitems: Boolean;
    begin
        Travelheader.SetCurrentkey("No.");
        Travelheader.SetRange(Type, Travelheader.Type::Stamp);
        Travelheader.SetRange("Approval Status", Travelheader."approval status"::Open);
        Travelheader.SetRange("Raised By", UserId);
        if Travelheader.FindFirst then
            openitems := true;

        if openitems = true then Error('Kindly utilize the open record on the page');
    end;

    trigger OnOpenPage()
    begin
        //SETFILTER("Raised By", USERID);
        if "Approval Status" = "approval status"::Open then
            EditFields := true else
            EditFields := false;
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
        Travelheader: Record "Travel Request Header";
        Text001: label 'Do you want to recall the approval request';
        FileName: Text;
        EditFields: Boolean;
        Text002: label 'Do you want to Archive the approval request?';

    local procedure InsertTravelLine()
    begin
        //HRSetup.GET;

        //IF Location <> '' THEN
        //LocationCODE := Location;

        //Loc.GET(LocationCODE);

        TravelLine.Init;
        TravelLine."Document No." := "No.";
        TravelLine."Line No." := TravelLine."Line No." + 10000;
        TravelLine."Entry Type" := TravelLine."entry type"::Travel;
        TravelLine.Location := Location;
        TravelLine."Currency Code" := "Currency Code";
        TravelLine."Employee No." := "Employee No.";
        TravelLine."Employee Name" := "Employee Name";
        TravelLine."Transaction Date" := "Raised Date";
        TravelLine."Travel Date" := "Travel From Date";
        TravelLine."Travel From" := "Travel From";
        TravelLine."Travel To" := "Travel To";
        TravelLine.Insert;
    end;
}

