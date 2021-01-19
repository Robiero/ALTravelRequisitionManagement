Page 50065 "Travel Request"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Travel Request Header";
    SourceTableView = where(Type = filter(Travel));

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
                field(EmployeeGrade; "Employee Grade")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = Basic;
                    Visible = true;
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
                field(Approver; Approver)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(ApprovalStatus; "Approval Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(HRBPApprover; "HRBP Approver")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(HRManagerApprover; "HR Manager Approver")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(HRApprovalStatus; "HR Approval Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Location; Location)
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                group(TripDetails)
                {
                    Caption = 'Trip Details';
                    field(TravelOrigin; "Travel From")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Travel Origin';
                    }
                    field(TravelDestination; "Travel To")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Travel Destination';
                    }
                    field(TravelDate; "Travel From Date")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Travel Date';
                    }
                    field(TravelReturnDate; "Travel To Date")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Travel Return Date';
                    }
                    field(NoofNights; "No. of Days")
                    {
                        ApplicationArea = Basic;
                        Caption = 'No. of Nights';
                        DecimalPlaces = 0 : 0;
                        Editable = false;
                    }
                    field(TravelMode; "Travel Mode")
                    {
                        ApplicationArea = Basic;

                        trigger OnValidate()
                        begin
                            InsertTravelLine;
                        end;
                    }
                    field(AccomodationType; "Accomodation Type")
                    {
                        ApplicationArea = Basic;
                    }
                    field(TravelPurposeCategory; "Travel Purpose Category")
                    {
                        ApplicationArea = Basic;
                    }
                    field(TravelPurpose; "Travel Purpose")
                    {
                        ApplicationArea = Basic;
                        MultiLine = true;

                        trigger OnValidate()
                        begin
                            "Travel Purpose" := UpperCase("Travel Purpose");
                        end;
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                    field(ApprovalRemarks; "Approval Remarks")
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
                field(HRApprovalBy; "HR Approval By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(HRApprovalDate; "HR Approval Date")
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
                        if "Travel Purpose" = '' then
                            Error('Kindly note it is mandatory to insert travel purpose in the travel request');
                        TestField("Travel Purpose Category");
                        TestField("Approval Status", "approval status"::Open);
                        TestField("Travel From");
                        TestField("Travel From Date");
                        TestField("Travel To");
                        TestField("Travel To Date");
                        TestField("Approval Status", "approval status"::Open);
                        TravelMgmt.SubmitTravelForApproval(Rec);
                    end;
                }
                action(SubmitforHRApproval)
                {
                    ApplicationArea = Basic;
                    Caption = 'Submit for HR Approval';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        TestField("HR Approval Status", "approval status"::Open);
                        TravelMgmt.SubmitForHRTravelApproval(Rec);
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
                        //RO.UTL.09.10.19
                        //TO CANCEL APPROVAL AND PICK SUBSTITUTE IF APPROVER HAS DELEGATED
                        UserSetup.Get(UserId);
                        Branch := UserSetup.Branch;
                        Department := UserSetup."Department Code";
                        Approver := '';
                        if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then begin
                            Approver := UserSetup.Substitute
                        end else
                            Approver := UserSetup."Approver ID";

                        "HRBP Approver" := '';
                        if Type = Type::Travel then begin
                            UserSetup.TestField("Dept HRBP");
                            UserSetup.Reset;
                            UserSetup.SetRange("User ID", UserId);
                            if UserSetup.Find('-') then begin
                                if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                                    "HRBP Approver" := UserSetup.Substitute
                                else
                                    "HRBP Approver" := UserSetup."Dept HRBP";

                                "HR Manager Approver" := '';
                                UserSetup.Reset;
                                UserSetup.SetRange("HR Manager", true);
                                if UserSetup.Find('-') then begin
                                    if ((UserSetup."Approval Delegated") and (UserSetup."Delegation Expiry" >= Today)) then
                                        "HR Manager Approver" := UserSetup.Substitute
                                    else
                                        "HR Manager Approver" := UserSetup."User ID";

                                end;
                            end;
                        end;
                        //END
                    end;
                }
                action(RejectRequest)
                {
                    ApplicationArea = Basic;
                    Caption = 'Reject Request';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        TestField("Raised By", UserId);

                        if ("Approval Status" = "approval status"::Approved) then
                            Error(Text004)
                        else begin
                            "Approval Status" := "approval status"::Canceled;
                            Modify;
                        end;
                    end;
                }
                action(CreatePO)
                {
                    ApplicationArea = Basic;
                    Caption = 'Create PO';

                    trigger OnAction()
                    begin
                        TravelMgmt.CreateAccomodationPurchaseOrder(Rec);
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
                        RptReqn: Report "Travel Request";
                        saveFile: Boolean;
                        TrRequestNo: Text;
                        FileName: Text;
                    begin
                        /*
                        //TESTFIELD(Status,Status::Released);
                         travelheader.SETRANGE(Type,travelheader.Type::Travel);
                         travelheader.SETRANGE("No.","No.");
                         RptReqn.SETTABLEVIEW(travelheader);
                         RptReqn.RUNMODAL;
                         */

                        saveFile := true;
                        travelheader.SetRange("No.", Rec."No.");
                        RptReqn.SetTableview(travelheader);
                        //TrRequestNo := 'Travel Request_' + DelChr(Rec."No.", '=', '/') + '.pdf';
                        // FileName := '\\172.16.60.3\GAB-Users\Procurement-Administration\ERP System\ERP Documents To Print\Docs To Print - Travel Requisitions\' + TrRequestNo;
                        //saveFile := RptReqn.SaveAsPdf(FileName);
                        //Message(TrRequestNo);

                    end;
                }
                action("Re-open Travel Requisition")
                {
                    ApplicationArea = SUITE;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        "Approval Status" := "approval status"::Open;
                        Modify;
                        Message('Travel Requisition Approval has been Re-Open');
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
        Travelheader.SetRange(Type, Travelheader.Type::Travel);
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
        Travelheader: Record "Travel Request Header";
        Text001: label 'Do you want to recall the approval request';
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

