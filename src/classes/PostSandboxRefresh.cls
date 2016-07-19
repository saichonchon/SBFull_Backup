/**
 * PostSandboxRefresh
 * Author: Bala Rajagopal
 * Purpose: Runs after a Sandbox Creation or Refresh when selected as the Apex Class to be run ("Sandbox Options" page in the sandbox creation/refresh process)
 * Ticket: BAP-3907
 * 
 */
global class PostSandboxRefresh implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
      	//start the Contact Email Change process for the sandbox
      	BatchContactEmailChangeForSandbox BC = new BatchContactEmailChangeForSandbox();
		database.executebatch(BC);
    }
  }