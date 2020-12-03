"""" Rosie Specific Functionality """"

""" Will print the world + objects of the given state in a easy to read format
function! PrintRosieWorld(state_id)
Python << EOF

from pysoarlib.util import PrintoutIdentifier
from rosie.tools import world_to_str

# Print the given state
state_id = PrintoutIdentifier.create(agent, vim.eval("a:state_id"), 1)
world_sym = state_id.GetChildId('world').GetIdentifierSymbol()

# Print out the world using the world_to_string formatter
world_id = PrintoutIdentifier.create(agent, world_sym, 4)
writer.write(world_to_str(world_id))

EOF
endfunction

""" Will print a summarized description of the given task-operator identifier
function! PrintTaskOperator(task_id)
Python << EOF

from pysoarlib.util import PrintoutIdentifier
from rosie.tools import task_to_str

task_sym = vim.eval("a:task_id")
task_id = PrintoutIdentifier.create(agent, task_sym, 6)
writer.write(task_to_str(task_id))

EOF
endfunction

""" Will print the task concept network for the task with the given handle
function! PrintTCN(task_handle)
Python << EOF

from pysoarlib.util import PrintoutIdentifier
from rosie.tools import tcn_to_str

task_h = vim.eval("a:task_handle")
query_res = agent.execute_command("smem -q {(<t> ^handle " + task_h + ")}")
if query_res.startswith("(@"):
	tcn_lti = query_res.split()[0].replace("(", "")
	tcn_id = PrintoutIdentifier.create(agent, tcn_lti, 50)
	writer.write(tcn_to_str(tcn_id))
else:
	writer.write("Query for task " + task_h + " failed")
	writer.write(query_res)
EOF
endfunction

"""""""""""""""""""""""""" SENDING MESSAGES """"""""""""""""""""""""'

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
	msg = msg.strip()
	if len(msg) == 0:
		return
	if not msg.startswith("!CMD"):
		writer.write("Instr: " + msg, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True)
	agent.send_message(msg)

def insert_text(txt):
	vim.command('execute "normal! i' + txt + '\<Esc>"')
EOF

function! SendMessageToRosie()
	let msg = input('Enter message: ', "", "customlist,ListRosieMessages")
	Python send_message(vim.eval("msg"))
endfunction


""" Will set up the environment-specific interface code for different rosie domains
"   env can be one of { internal, mobilesim, ai2thor, cozmo }
function! SetupRosieInterface(env)
	if a:env =~ "internal"
		return
	elseif a:env =~ "mobilesim"
		Python setup_mobilesim_interface()
	elseif a:env =~ "ai2thor"
		Python setup_ai2thor_interface()
	elseif a:env =~ "cozmo"
		Python setup_cozmo_interface()
	else
		echom "Unrecognized rosie environment: ".a:env
	endif
endfunction


"""""""""""""""""""""""""" MOBILE SIMULATOR """"""""""""""""""""""""'
Python << EOF
def setup_mobilesim_interface():
	from mobilesim.rosie import LCMConnector, MobileSimCommandConnector, MobileSimPerceptionConnector, MobileSimActuationConnector

	lcmConn = LCMConnector(agent)
	agent.connectors["lcm"] = lcmConn
	agent.connectors["perception"] = MobileSimPerceptionConnector(agent, lcmConn.lcm)
	agent.connectors["perception"].print_handler = lambda message: writer.write(message)
	agent.connectors["actuation"] = MobileSimActuationConnector(agent, lcmConn.lcm)
	agent.connectors["actuation"].print_handler = lambda message: writer.write(message)
	agent.connectors["commands"] = MobileSimCommandConnector(agent, lcmConn.lcm)
	agent.connectors["commands"].print_handler = lambda message: writer.write(message)
EOF

"""""""""""""""""""""""""" AI2THOR SIMULATOR """"""""""""""""""""""""'

Python << EOF
def setup_ai2thor_interface():
	from rosiethor import MapUtil, NavigationHelper, Ai2ThorSimulator, PerceptionConnector, RobotConnector

	scene_name = agent.settings.get("ai2thor_scene", "testing")

	simulator = Ai2ThorSimulator()

	agent.connectors["perception"] = PerceptionConnector(agent, simulator)
	agent.connectors["perception"].print_handler = lambda message: writer.write(message)
	agent.connectors["robot"] = RobotConnector(agent, simulator)
	agent.connectors["robot"].print_handler = lambda message: writer.write(message)

	simulator.start(scene_name)
EOF

""" Will enter a mode where keypresses will send movement commands to the ai2thor robot
""" Move with WASD, Rotate with Q/E, Look up/down with R/F
""" Stop with Escape or X
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


"""""""""""""""""""""""""" COZMO ROBOT """"""""""""""""""""""""'

Python << EOF
def setup_cozmo_interface():
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
		SOAR_GLOBAL_STATE["running"] = True
		while SOAR_GLOBAL_STATE["running"]:
			sleep(0.1)

	def cozmo_thread():
		cozmo.run_program(create_robot_connector)

	run_thread = Thread(target=cozmo_thread)
	run_thread.start()
EOF
