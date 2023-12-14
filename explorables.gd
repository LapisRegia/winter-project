extends Resource

class_name Explorables

# statuses - updated during runtime
export var discovered : bool = false
export var traversed : bool = false
export var rangeFindPressed : bool = false
export var dummyFirePressed : bool = false
export var radioFireShot : bool = false
export(Array, int) var characterHasTraversed # should this be a bool array?

# prerequisites
export(Array, int) var requiredCharacters  # to be compared with characterInNode

# location tab
export var locationHeader : String
export var image : Texture
export var description : String

# Trajectory calculation
export var dummyResult : String
export var rangeResult : String
export var distance : int
export var angleRange : String
export var anglePrecise : String

# Angle Fix
export var targetAngle : int # 15 deg
export var std_dev : int # +- .5 deg

# Notes | 0 - Yumi, 1 - Yume, 2 - Yuuko
export(Array, String) var notesArray 

