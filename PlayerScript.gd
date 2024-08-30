extends CharacterBody2D;

#Export exports the variable and sends to the editor.  This allows for easier time modifying them for non-programmers.
@export var health : int = 5;
@export var moveSpeed : float = 100;

#onready runs when the node is created in the scene.

@onready var facingDirection = 0;
@onready var direction = Vector2.ZERO #Initialize the direction for the player.


enum directions { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3, UP_LEFT = 4, UP_RIGHT = 5, DOWN_RIGHT = 6, DOWN_LEFT = 7 }


@onready var aliveState = 0; #0 - alive, 1 - dying, 2 - dead
@onready var moveState = 0; #0 - idling, 1 - moving, 2 - damaged

@onready var selfRef = self;

#Ticker section.
@onready var directionChangeTick = 0;






func animationPlay():
	print("Test");


	
func _physics_process(_delta):
	
	
	
	match aliveState:
		0:
			aliveAction(_delta);
		1:
			print("Dying");
		2:
			print("Dead");


func _input(event):
	if event is InputEventMouseMotion:
		var cursorDirectionX: float = (1.00 * event.relative.x);
		var cursorDirectionY: float = event.relative.y;
		
		#Get magnitude before calling trig functions
		var magX: float = ( float(cursorDirectionX) / sqrt( (cursorDirectionX * cursorDirectionX) + (cursorDirectionY * cursorDirectionY) ) );
		var magY: float = ( float(cursorDirectionY) / sqrt( (cursorDirectionX * cursorDirectionX) + (cursorDirectionY * cursorDirectionY) ) );
		
		var directionDegree = 0;
		
		#Quadrant One
		#DR - ++ - Sin Cos Tan
		if(cursorDirectionX > 0 and cursorDirectionY > 0):
			print("Quad One");
			directionDegree = int(rad_to_deg(acos(magX)));
			print("Arc cos: ", directionDegree);
			print();
		#Quadrant Two
		#DL - -+ - Sin
		elif(cursorDirectionX < 0 and cursorDirectionY > 0):
			print("Quad Two");
			directionDegree =  int(180 - rad_to_deg(asin(magY)));
			print("Arc Sin: ", directionDegree);
			print();
		#Quadrant Three
		#UL - -- - Tan
		elif(cursorDirectionX < 0 and cursorDirectionY < 0):
			print("Quad Three");
			directionDegree = int(270 - rad_to_deg(atan((magY/magX))));
			print("Arc Tan: ", directionDegree);
			print();
		#Quadrant Four
		#UR - +- - Cos
		elif(cursorDirectionX > 0 and cursorDirectionY < 0):
			print("Quad Four");
			directionDegree = int(360 - rad_to_deg(acos(magX)))
			print("Arc cos: ", directionDegree);
			print();





func aliveAction(_delta):
	#This is basically a long if tree for each key.
	direction = Input.get_vector("left", "right", "up", "down"); #This is basically a long if tree for each key.
	
	
		
	velocity = direction * (moveSpeed); 
	
	
		
		
	move_and_collide(velocity * _delta);
