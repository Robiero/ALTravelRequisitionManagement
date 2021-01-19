Table 50061 "Approval Matrix"
{
    DrillDownPageID = "Approval Matrix";
    LookupPageID = "Approval Matrix";

    fields
    {
        field(1; "Approver ID"; Code[50])
        {
            NotBlank = true;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                LUserSetupREC: Record "User Setup";
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(2; Branch; Code[20])
        {
            NotBlank = true;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            var
                LGLSetupREC: Record "General Ledger Setup";
                LDimValREC: Record "Dimension Value";
            begin
            end;
        }
        field(3; "User Status"; Option)
        {
            CalcFormula = lookup (User.State where("User Name" = field("Approver ID")));
            Editable = false;
            FieldClass = FlowField;
            OptionMembers = Enabled,Disabled;
        }
        field(4; "Travel Approver"; Boolean)
        {
            InitValue = false;
        }
        field(5; "Travel HR Approver"; Boolean)
        {
            InitValue = false;
        }
    }

    keys
    {
        key(Key1; Branch, "Approver ID")
        {
            Clustered = true;
        }
        key(Key2; "Approver ID")
        {
        }
    }

    fieldgroups
    {
    }
}

