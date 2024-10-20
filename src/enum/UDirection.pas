unit UDirection;

interface

type
  EDirection1D = (
    E1_Left,  {Y-}
    E1_Right  {Y+}
  );

  EDirection2D = (
    E2_Left,  {Y-}
    E2_Right, {Y+}
    E2_Up,    {Z+}
    E2_Down   {Z-}
  );

  EDirection3D = (
    E3_Front, {X+}
    E3_Back,  {X-}
    E3_Left,  {Y-}
    E3_Right, {Y+}
    E3_Up,    {Z+}
    E3_Down   {Z-}
  );

  EDirection4D = (
    E4_Front, {X+}
    E4_Back,  {X-}
    E4_Left,  {Y-}
    E4_Right, {Y+}
    E4_Up,    {Z+}
    E4_Down,  {Z-}
    E4_Ana,   {W+}
    E4_Kata   {W-}
  );

implementation

end.
