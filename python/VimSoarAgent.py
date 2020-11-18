""" Creates a soar agent to use in the vim debugger and displays common state info """
import sys

from pysoarlib import SoarAgent

from VimWriter import VimWriter

class VimSoarAgent(SoarAgent):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        SoarAgent.__init__(self, config_filename=config_filename, 
                print_handler = lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True),
                spawn_debugger=False, write_to_stdout=True, **kwargs)

        self.last_soar_command = None
        self.last_print_command = None

    def update_debugger_info(self):
        cur_state = self.agent.ExecuteCommandLine("p <s>", False)
        self.vim_writer.write(cur_state, VimWriter.SIDE_PANE_TOP, clear=True, scroll=False)
        prefs = self.agent.ExecuteCommandLine("preferences <s> operator --names", False)
        self.vim_writer.write(prefs, VimWriter.SIDE_PANE_MID, clear=True, scroll=False)
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=True)

    def _on_init_soar(self):
        super()._on_init_soar()
        self.last_soar_command = None
        self.last_print_command = None

    def execute_command(self, cmd, print_res=False):
        if cmd.startswith("p ") or cmd.startswith("print "):
            self.last_print_command = cmd
        self.last_soar_command = cmd
        return super().execute_command(cmd, print_res)

    def start_buffering_output(self):
        self.buffered_output = []
        self.print_handler = lambda message: self.buffered_output.append(message)

    def stop_buffering_output(self):
        self.print_handler = lambda message: self.vim_writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True)
        self.print_handler("\n".join(self.buffered_output))
        self.buffered_output = []

    def repeat_last_print(self, depth_change=0, print_res=False):
        """ Will redo the last print command, with the option to change the depth """
        if self.last_print_command is None:
            result = "No saved print command"
        else:
            args = self.last_print_command.split()
            # Here we assume the previous command is either 'p <s2>' or 'p <s2> -d 3'
            if len(args) < 3:
                args.append('-d')
            if len(args) < 4:
                args.append(str(1))
            args[3] = str(int(args[3])+depth_change)
            result = self.execute_command(" ".join(args), print_res)
        return result
