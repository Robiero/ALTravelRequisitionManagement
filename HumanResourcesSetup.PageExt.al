PageExtension 50004 pageextension50004 extends "Human Resources Setup"
{
    Caption = 'Human Resources Setup';
    PromotedActionCategories = 'New,Process,Report,Employee,Documents';
    layout
    {
        modify(Numbering)
        {
            Caption = 'Numbering';
        }
        modify("Employee Nos.")
        {
            ToolTip = 'Specifies the number series code to use when assigning numbers to employees.';
        }
        modify("Base Unit of Measure")
        {
            ToolTip = 'Specifies the base unit of measure, such as hour or day.';
        }
        addafter(Numbering)
        {
            group("Petty Cash")
            {
                Caption = 'Petty Cash';
                field("Petty Cash Nos."; "Petty Cash Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Petty Cash Account"; "Petty Cash Account")
                {
                    ApplicationArea = Basic;
                }
                field("Petty Control Account"; "Petty Control Account")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Travel Requisition")
            {
                Caption = 'Travel Requisition';
                field("Travel Requisition Nos."; "Travel Requisition Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Business Cards Nos"; "Business Cards Nos")
                {
                    ApplicationArea = Basic;
                }
                field("Stamp Nos"; "Stamp Nos")
                {
                    ApplicationArea = Basic;
                }
                field("LCY Per Diem AC"; "LCY Per Diem AC")
                {
                    ApplicationArea = Basic;
                }
                field("USD Per Diem AC"; "USD Per Diem AC")
                {
                    ApplicationArea = Basic;
                }
                field("Staff Debtors"; "Staff Debtors")
                {
                    ApplicationArea = Basic;
                }
                field("Tax Threshold"; "Tax Threshold")
                {
                    ApplicationArea = Basic;
                }
                field("Enable Travel Notifications"; "Enable Travel Notifications")
                {
                    ApplicationArea = Basic;
                    Caption = 'Enable Email Notifications';
                }
                field("Ticketing Admin Email"; "Ticketing Admin Email")
                {
                    ApplicationArea = Basic;
                }
                field("Finance Admin Email"; "Finance Admin Email")
                {
                    ApplicationArea = Basic;
                }
                field("Procurement Admin Email"; "Procurement Admin Email")
                {
                    ApplicationArea = Basic;
                }
                field("Accomodation Account"; "Accomodation Account")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }
    actions
    {
        modify("Human Res. Units of Measure")
        {
            Caption = 'Human Res. Units of Measure';
            ToolTip = 'Set up the units of measure, such as DAY or HOUR, that you can select from in the Human Resources Setup window to define how employment time is recorded.';
        }
        modify("Causes of Absence")
        {
            Caption = 'Causes of Absence';
            ToolTip = 'Set up reasons why an employee can be absent.';
        }
        modify("Causes of Inactivity")
        {
            Caption = 'Causes of Inactivity';
            ToolTip = 'Set up reasons why an employee can be inactive.';
        }
        modify("Grounds for Termination")
        {
            Caption = 'Grounds for Termination';
            ToolTip = 'Set up reasons why an employment can be terminated.';
        }
        modify(Unions)
        {
            Caption = 'Unions';
            ToolTip = 'Set up different worker unions that employees may be members of, so that you can select it on the employee card.';
        }
        modify("Employment Contracts")
        {
            Caption = 'Employment Contracts';
            ToolTip = 'Set up the different types of contracts that employees can be employed under, such as Administration or Production.';
        }
        modify(Relatives)
        {
            Caption = 'Relatives';
            ToolTip = 'Set up the types of relatives that you can select from on employee cards.';
        }
        modify("Misc. Articles")
        {
            Caption = 'Misc. Articles';
            ToolTip = 'Set up types of company assets that employees use, such as CAR or COMPUTER, that you can select from on employee cards.';
        }
        modify(Confidential)
        {
            Caption = 'Confidential';
            ToolTip = 'Set up types of confidential information, such as SALARY or INSURANCE, that you can select from on employee cards.';
        }
        modify(Qualifications)
        {
            Caption = 'Qualifications';
            ToolTip = 'Set up types of qualifications, such as DESIGN or ACCOUNTANT, that you can select from on employee cards.';
        }
        modify("Employee Statistics Groups")
        {
            Caption = 'Employee Statistics Groups';
            ToolTip = 'Set up salary types, such as HOURLY or MONTHLY, that you use for statistical purposes.';
        }
    }
}

