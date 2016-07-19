public interface iBatchMonitor {
	String GetJobName();
	String GetStatus();
	Integer GetTotalRecords();
	Integer GetTotalRecordsProcessed();
	Integer GetPercentCompleted();
}