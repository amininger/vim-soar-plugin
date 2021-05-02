""" Initializes a Rosie agent in the soar vim debugger and will display chat and action info in different panes """
import sys
import vim

from rosie import RosieClient
from rosie.events import *

from VimWriter import VimWriter
from VimConnector import VimConnector

class VimRosieClient(RosieClient):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        print_main_page = lambda message: self.vim_writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True)
        RosieClient.__init__(self, config_filename=config_filename, print_handler=print_main_page,
                spawn_debugger=False, write_to_stdout=True, use_action_stack_connector=True, **kwargs)

        self.vim_connector = VimConnector(self, writer)
        self.add_connector("vim", self.vim_connector)

        if len(self.messages) > 0:
            lines = ( line.replace('"', '|') for line in self.messages )
            vim.command('let g:rosie_messages = ["' + '","'.join(lines) + '"]')

        self.add_event_handler(AgentMessageSent, lambda e: 
            writer.write(e.message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True))
        self.add_event_handler(InstructorMessageSent, lambda e: 
            writer.write(e.message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True))

        self.add_event_handler(TaskStarted, lambda e: 
            writer.write("  "*(e.depth-1) + "> " + e.task_desc, VimWriter.SIDE_PANE_MID, clear=False, scroll=True, strip=False))
        self.add_event_handler(TaskCompleted, lambda e: 
            writer.write("  "*(e.depth-1) + "< " + e.task_desc, VimWriter.SIDE_PANE_MID, clear=False, scroll=True, strip=False))

    def execute_command(self, cmd, print_res=False):
        if self.has_connector('vim'):
            self.vim_connector.record_command(cmd)
        super().execute_command(cmd, print_res)

    def update_debugger_info(self):
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=True)

    def connect(self):
        super().connect()
        self.agent.RunSelf(1)

