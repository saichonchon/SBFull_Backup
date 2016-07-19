/**
 * Utilities
 * Author: Bala Rajagopal
 * Purpose: Utility classes that can be used in other classes
 * Ticket: BAP-3907
 * 
 */
public class Utilities {
    
    public static Boolean checkEmail (String semail) {
        String InputString = semail;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        // Then instantiate a new Matcher object "MyMatcher"
        Matcher MyMatcher = MyPattern.matcher(InputString);
        
        if (!MyMatcher.matches()) {
        	return FALSE;
        }
        else {
        	return TRUE;
        }
    } //end email check
    
}