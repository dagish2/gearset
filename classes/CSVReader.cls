/*
    Class Name: CSVReader
    Description : Controller for Manage User License feature in package configuration page.
    Created By : Ajay Chauhan ,  8/3/2016 10:22 PM
    Last Modified By : Ajay Chauhan ,  8/3/2016 11:11 PM
*/


public class CSVReader {
    
    private static transient string COMMA = ',';
    private static transient string NL = '\n';
    private static transient string QUOTE = '"';
    private static transient string DOUBLE_QUOTE = '""';
	private static transient string OBJECTTOPARSE = '';
    public static List<List<string>> Parse( string csvString, string obj )
    {
        OBJECTTOPARSE = obj;
		List<List<string>> linesValues = new List<List<string>>();
        for(String line:csvString.split('\n')){
			linesValues.add(ReadLine(line));
        }
        return linesValues;
    }
    public static List<String> ReadLine(String csvString)
    {
        integer position = 0;
        integer csvStringLength = csvString.length();
        integer startPos = position;
        string currentValue;
        integer cAt, nlAt, foundAt;

        List<string> tmpValues = new List<string>();
        while (position < csvStringLength)
        {
            cAt = csvString.indexOf( COMMA, position );
            nlAt = csvString.indexOf( NL, position );
            foundAt = Math.min( cAt, nlAt );
            if( foundAt == -1 )
                    foundAt = Math.max( cAt, nlAt );


            if (foundAt == -1)
            {
                currentValue = csvString.substring(startPos);
                position = csvStringLength;
            }
            else
            {
                currentValue = csvString.substring(startPos, foundAt );
                position = foundAt + 1;
            }

            if( !currentValue.startsWith( QUOTE ) )
            {
                tmpValues.add( currentValue );

                if( foundAt == nlAt )
                    break;

                startPos = position;
            }
            else if( currentValue.endsWith( QUOTE ) && !currentValue.endsWith( DOUBLE_QUOTE ) )
            {
                if( currentValue.indexOf( DOUBLE_QUOTE ) == -1 )
                    tmpValues.add( currentValue.substring( 1, currentValue.length() - 1 ) );
                else
                    tmpValues.add( currentValue.substring( 1, currentValue.length() - 1 ).replace( DOUBLE_QUOTE, QUOTE ) );
                    
                if( foundAt == nlAt )
                    break;
                
                startPos = position;
            }
        }
        currentValue = currentValue.substring(1,currentValue.length()-2);
        tmpValues.add(currentValue);
        return tmpValues;
    }
}