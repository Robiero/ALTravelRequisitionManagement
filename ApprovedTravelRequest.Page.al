Page 50071 "Approved Travel Request"
{
    DeleteAllowed = false;
    PageType = Document;
    SourceTable = "Travel Request Header";
    SourceTableView = where("Approval Status" = filter(Approved));

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; "No.")
                {
                    ApplicationArea = Basic;

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
                    field(HRApprovalRemarks; "HR Approval Remarks")
                    {
                        ApplicationArea = Basic;
                    }
                }
            }
            part(Control24; "Travel Request Subpage")
            {
                SubPageLink = "Document No." = field("No.");
            }
            group(PurchaseOrders)
            {
                Caption = 'Purchase Orders';
                field(TravelVendorNo; "Travel Vendor No.")
                {
                    ApplicationArea = Basic;
                }
                field(AccomodationVendorNo; "Accomodation Vendor No.")
                {
                    ApplicationArea = Basic;
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
                    Visible = false;

                    trigger OnAction()
                    begin
                        if "Travel Purpose" = '' then
                            Error('Kindly note it is mandatory to insert travel purpose Category and Comments in the travel request');
                        TestField("Travel Purpose Category");
                        TestField("Approval Status", "approval status"::Open);
                        TestField("Travel From");
                        TestField("Travel From Date");
                        TestField("Travel To");
                        TestField("Travel To Date");

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

                    trigger OnAction()
                    begin
                        TestField("HR Approval Status", "approval status"::Open);
                        Mandatory := false;
                        //setting mandatory fields on line type per diem RO.15.11.19 BEGIN
                        TravelLine.Reset;
                        TravelLine.SetRange("Document No.", Rec."No.");
                        if TravelLine.FindFirst then begin
                            repeat
                                if TravelLine."Entry Type" = TravelLine."entry type"::"Per Diem" then begin
                                    if TravelLine."Total Amount" = 0 then
                                        Error('Kindly populate the per diem line with respective amounts');
                                end;
                            until TravelLine.Next = 0;
                        end;
                        /*
                      IF TravelLine.FINDFIRST THEN BEGIN
                        TravelLine.TESTFIELD("Entry Type");
                        TravelLine.TESTFIELD(Quantity);
                        TravelLine.TESTFIELD("Unit Amount");
                        TravelLine.TESTFIELD("Total Amount");
                        END;
                        */
                        //END
                        TravelMgmt.SubmitForHRTravelApproval(Rec);

                    end;
                }
                action(RejectRequest)
                {
                    ApplicationArea = Basic;
                    Caption = 'Reject Request';
                    Enabled = false;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

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
                action("Re-open HR Travel Requisition")
                {
                    ApplicationArea = SUITE;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        if "Approval Status" <> "approval status"::Approved then begin
                            "HR Approval Status" := "hr approval status"::Open;
                            Modify;
                            Message('Travel Requisition Approval has been Re-Open');
                        end;
                    end;
                }
                action(CreatePO)
                {
                    ApplicationArea = Basic;
                    Caption = 'Create PO';

                    trigger OnAction()
                    begin
                        PUrchaseOrder.Reset;
                        PUrchaseOrder.SetRange("Quote No.", "No.");
                        if PUrchaseOrder.Find('-') then begin

                            Error('The Purchase Order already exist');
                        end else begin
                            TravelMgmt.CreateAccomodationPurchaseOrder(Rec);
                        end;
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
                        if "Approval Status" <> "approval status"::Approved then Error('You cannot print a document that is not yet approved');
                        if "HR Approval Status" <> "hr approval status"::Approved then Error('You cannot print a document that is not yet approved');

                        //TESTFIELD(Status,Status::Released);
                        travelheader.SetRange(Type, travelheader.Type::Travel);
                        travelheader.SetRange("No.", "No.");
                        RptReqn.SetTableview(travelheader);
                        RptReqn.RunModal;

                        /*                         saveFile:=true;
                                                travelheader.SetRange("No.",Rec."No.");
                                                RptReqn.SetTableview(travelheader);
                                                TrRequestNo:='Travel Request_'+DelChr(Rec."No.",'=','/')+'.pdf';
                                                FileName:='\\172.16.60.3\GAB-Users\Procurement-Administration\ERP System\ERP Documents To Print\Docs To Print - Travel Requisitions\'+ TrRequestNo;
                                                saveFile:=RptReqn.SaveAsPdf(FileName);
                                                Message(TrRequestNo); */
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

    trigger OnInit()
    begin
        TravelLine.Reset;

        TravelLine.SetRange("Document No.", TravelHeader."No.");
        if TravelLine.FindFirst then begin

            TravelLine.Department := TravelHeader.Department;
            TravelLine.Branch := TravelHeader.Branch;
            TravelLine."line status" := TravelHeader."HR Approval Status";
            TravelLine.Modify;

        end;
    end;

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

    trigger OnModifyRecord(): Boolean
    begin
        TravelLine.Reset;

        TravelLine.SetRange("Document No.", TravelHeader."No.");
        if TravelLine.FindFirst then begin

            TravelLine.Department := TravelHeader.Department;
            TravelLine.Branch := TravelHeader.Branch;
            TravelLine.Status := TravelHeader."HR Approval Status";
            TravelLine.Modify;

        end;
    end;

    trigger OnOpenPage()
    begin
        TravelLine.Reset;

        TravelLine.SetRange("Document No.", TravelHeader."No.");
        if TravelLine.FindFirst then begin

            TravelLine.Department := TravelHeader.Department;
            TravelLine.Branch := TravelHeader.Branch;
            TravelLine."line status" := TravelHeader."HR Approval Status";
            TravelLine.Modify;

        end;
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
        PUrchaseOrder: Record "Purchase Header";
        TravelHeader: Record "Travel Request Header";
        Mandatory: Boolean;
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

