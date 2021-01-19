Page 50070 "Posted Travel Request Subpage"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Posted Travel Request Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(DocumentNo; "Document No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(LineNo; "Line No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(EmployeeNo; "Employee No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field(EmployeeName; "Employee Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field(EntryType; "Entry Type")
                {
                    ApplicationArea = Basic;
                }
                field(PerDiemType; "PerDiem Type")
                {
                    ApplicationArea = Basic;
                    Editable = PerDiemTypeEditable;
                }
                field(BoardType; "Board Type")
                {
                    ApplicationArea = Basic;
                    Editable = BoardTypeEditable;
                }
                field(TravelDate; "Travel Date")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field(TravelFrom; "Travel From")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field(TravelTo; "Travel To")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field(DepartureTime; "Departure Time")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field(ArrivalTime; "Arrival Time")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field(FlightNo; "Flight No.")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                    Visible = FlightVisible;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic;
                }
                field(UnitAmount; "Unit Amount")
                {
                    ApplicationArea = Basic;
                }
                field(TotalAmount; "Total Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        ControlEdit;
    end;

    trigger OnAfterGetRecord()
    begin
        GetTravelHeader;
        if TravelHeader."Travel Mode" = TravelHeader."travel mode"::Flight then begin
            FlightVisible := true;
        end;
        ControlEdit;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ControlEdit;
    end;

    trigger OnOpenPage()
    begin
        PerDiemTypeEditable := true;
        BoardTypeEditable := true;
    end;

    var
        FlightVisible: Boolean;
        TravelHeader: Record "Travel Request Header";
        FieldEditable: Boolean;
        PerDiemTypeEditable: Boolean;
        BoardTypeEditable: Boolean;

    local procedure GetTravelHeader()
    begin
        TestField("Document No.");
        TravelHeader.SetRange("No.", "Document No.");
        if TravelHeader.FindFirst then;
    end;

    local procedure ControlEdit()
    begin
        if "Entry Type" = "entry type"::Travel then
            FieldEditable := true
        else
            FieldEditable := false;

        if "Entry Type" <> "entry type"::"Per Diem" then
            PerDiemTypeEditable := false
        else
            PerDiemTypeEditable := true;

        if "Entry Type" <> "entry type"::Accomodation then
            BoardTypeEditable := false
        else
            BoardTypeEditable := true;
    end;
}

