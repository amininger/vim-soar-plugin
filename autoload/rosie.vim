"""" Rosie Specific Functionality """"

function! LaunchMobileSimRosie()
Python << EOF

from mobilesim.rosie import LCMConnector, MobileSimPerceptionConnector, MobileSimActuationConnector

lcmConn = LCMConnector(agent)
agent.connectors["lcm"] = lcmConn
agent.connectors["perception"] = MobileSimPerceptionConnector(agent, lcmConn.lcm)
agent.connectors["perception"].print_handler = lambda message: writer.write(message)
agent.connectors["actuation"] = MobileSimActuationConnector(agent, lcmConn.lcm)
agent.connectors["actuation"].print_handler = lambda message: writer.write(message)

EOF
endfunction

function! LaunchAi2ThorSimulator()
Python << EOF

from rosiethor import MapUtil, NavigationHelper, Ai2ThorSimulator, PerceptionConnector, RobotConnector

scene_name = agent.settings.get("ai2thor_scene", "testing")

simulator = Ai2ThorSimulator()

agent.connectors["perception"] = PerceptionConnector(agent, simulator)
agent.connectors["perception"].print_handler = lambda message: writer.write(message)
agent.connectors["robot"] = RobotConnector(agent, simulator)
agent.connectors["robot"].print_handler = lambda message: writer.write(message)

simulator.start(scene_name)

EOF
endfunction

function! LaunchCozmoRobot()
Python << EOF

import cozmo
import pysoarlib

from threading import Thread
from time import sleep

from cozmosoar.c_soar_util import COZMO_COMMANDS
from cozmosoar.cozmo_soar import CozmoSoar

def create_robot_connector(robot: cozmo.robot):
	cozmo_robot = CozmoSoar(agent, robot)
	for command in COZMO_COMMANDS:
		cozmo_robot.add_output_command(command)
	cozmo_robot.print_handler = lambda message: writer.write(message)
	agent.add_connector("cozmo", cozmo_robot)
	cozmo_robot.connect()
	GLOBAL_STATE["running"] = True
	while GLOBAL_STATE["running"]:
		sleep(0.1)

def cozmo_thread():
	cozmo.run_program(create_robot_connector)

run_thread = Thread(target=cozmo_thread)
run_thread.start()

EOF
endfunction

function! ListRosieMessages(A,L,P)
	if !exists("g:rosie_messages")
		let msgs = []
	else
		let msgs = g:rosie_messages
	endif

	let res = []
	let pattern = "^".a:A
	for msg in msgs
		if msg =~ pattern
			call add(res, msg)
		endif
	endfor
	return res
endfunction

Python << EOF
def send_message(msg):
	if len(msg.strip()) > 0:
		writer.write("Instr: " + msg, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True)
		agent.connectors["language"].send_message(msg)

def insert_text(txt):
	vim.command('execute "normal! i' + txt + '\<Esc>"')
EOF

function! SendMessageToRosie()
	let msg = input('Enter message: ', "", "customlist,ListRosieMessages")
	Python send_message(vim.eval("msg"))
endfunction


function! ControlAi2ThorRobot()
	let key = getchar()
	"Loop until either ESC or X is pressed
	while key != 27 && key != 120
		if key == 119 "W
			Python if simulator: simulator.exec_simple_command("MoveAhead")
		elseif key == 97 "A
			Python if simulator: simulator.exec_simple_command("MoveLeft")
		elseif key == 115 "S
			Python if simulator: simulator.exec_simple_command("MoveBack")
		elseif key == 100 "D
			Python if simulator: simulator.exec_simple_command("MoveRight")
		elseif key == 113 "Q
			Python if simulator: simulator.exec_simple_command("RotateLeft")
		elseif key == 101 "E
			Python if simulator: simulator.exec_simple_command("RotateRight")
		elseif key == 114 "R
			Python if simulator: simulator.exec_simple_command("LookUp")
		elseif key == 102 "F
			Python if simulator: simulator.exec_simple_command("LookDown")
		endif
		let key = getchar()
	endwhile
endfunction


Python << EOF

def parse_wmes(soar_output):
	soar_output = soar_output.replace("\n", " ")
	soar_output = soar_output.replace(")", "")
	id_info = soar_output.split("(")
	wmes = []
	for idi in id_info:
		tokens = idi.split()
		if len(tokens) == 0:
			continue
		root_id = tokens[0]
		i = 1
		while i < len(tokens):
			if tokens[i][0] != '^':
				i += 1
				continue
			att = tokens[i][1:]
			val = tokens[i+1]
			i += 2
			wmes.append( (root_id, att, val) )
	return wmes

def print_rosie_objects():
	wmes = parse_wmes(agent.get_command_result("pobjs -d 3"))
	object_strs = []
	object_ids = [ wme[2] for wme in wmes if wme[1] == 'object' ]
	for oid in object_ids:
		root_cat = next(wme[2] for wme in wmes if wme[0] == oid and wme[1] == 'root-category')
		pred_id  = next(wme[2] for wme in wmes if wme[0] == oid and wme[1] == 'predicates')
		preds = [ wme[2] for wme in wmes if wme[0] == pred_id and wme[1] != 'category' and wme[1] != 'volume' ]
		object_strs.append(root_cat + ' (' + oid + '): ' + ', '.join(preds))
	result = '\n======= Rosie Objects =======\n' + '\n'.join(object_strs) + '\n'
	insert_text(result)

def print_rosie_preds():
	wmes = parse_wmes(agent.get_command_result("ppreds -d 4"))
	preds = []
	pred_ids = [ wme[2] for wme in wmes if wme[1] == 'predicate' ]
	for pid in pred_ids:
		handle = next(wme[2] for wme in wmes if wme[0] == pid and wme[1] == 'handle')
		instances = [ wme[2] for wme in wmes if wme[0] == pid and wme[1] == 'instance' ]
		for ins in instances:
			obj1 = next(wme[2] for wme in wmes if wme[0] == ins and wme[1] == '1')
			obj1_cat = next(wme[2] for wme in wmes if wme[0] == obj1 and wme[1] == 'root-category')
			obj2 = next(wme[2] for wme in wmes if wme[0] == ins and wme[1] == '2')
			obj2_cat = next(wme[2] for wme in wmes if wme[0] == obj2 and wme[1] == 'root-category')
			preds.append(handle + '(' + obj1_cat + '[' + obj1 + '],' + obj2_cat + '[' + obj2 + '])')
	result = '\n======= Rosie Predicates =======\n' + '\n'.join(preds) + '\n'
	insert_text(result)

EOF

command! -nargs=0 PrintRosieObjects :Python print_rosie_objects()
command! -nargs=0 PrintRosiePredicates :Python print_rosie_preds()
