Page 50068 "Posted Travel Request"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Posted Travel Request Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; "No.")
                {
                    ApplicationArea = Basic;
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
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
                field(EmployeeGrade; "Employee Grade")
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
                field(Approver; Approver)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(ApprovalStatus; "Approval Status")
                {
                    ApplicationArea = Basic;
                }
                field(HRApprover; "HR Approver")
                {
                    ApplicationArea = Basic;
                }
                field(HRApprovalStatus; "HR Approval Status")
                {
                    ApplicationArea = Basic;
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
                    field(FromDate; "Travel From Date")
                    {
                        ApplicationArea = Basic;
                        Caption = 'From Date';
                    }
                    field(ToDate; "Travel To Date")
                    {
                        ApplicationArea = Basic;
                        Caption = 'To Date';
                    }
                    field(NoofDays; "No. of Days")
                    {
                        ApplicationArea = Basic;
                        DecimalPlaces = 0 : 0;
                        Editable = false;
                    }
                    field(TravelMode; "Travel Mode")
                    {
                        ApplicationArea = Basic;
                    }
                    field(AccomodationType; "Accomodation Type")
                    {
                        ApplicationArea = Basic;
                    }
                    field(TravelPurpose; "Travel Purpose")
                    {
                        ApplicationArea = Basic;
                        MultiLine = true;
                    }
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            part(Control22; "Posted Travel Request Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = field("No.");
            }
            group(HotelDetails)
            {
                Caption = 'Hotel Details';
                field(HotelNo; "Vendor No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Hotel No.';
                }
                field(HotelName; "Vendor Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Hotel Name';
                }
            }
            group(Approvals)
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
            group("Action")
            {
                Caption = 'Action';
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
                    begin
                        //TESTFIELD(Status,Status::Released);
                        travelheader.SetRange(Type, travelheader.Type::Travel);
                        travelheader.SetRange("No.", "No.");
                        RptReqn.SetTableview(travelheader);
                        RptReqn.RunModal;
                    end;
                }
            }
        }
    }
}

