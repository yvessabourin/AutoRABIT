global with sharing class guidGenerator {

 private static String kHexChars = '0123456789abcdef';

    global static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (integer i=0; i<16; i++) {

            nextByte = (Math.round(Math.random() * 255)-128) & 255;


            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
            
        }
		
		string part1 = '';
		string part2 = '';
		string part3 = '';
		string part4 = '';
		string part5 = '';		
		
		for (integer i=0; i<32; i++){

			if (i == 8){
				part1 = returnValue.substring(0, i) + '-';
			}
			
			if (i == 9){
				part2 = returnValue.substring(i - 1, i+3) + '-';
			}
			
			if (i == 13){
				part3 = returnValue.substring(i - 1, i+3) + '-';
			}
			
			if (i == 17){
				part4 = returnValue.substring(i - 1, i+3) + '-';
			}
			
			if (i == 21){
				part5 = returnValue.substring(i - 1);
			}									

		}
		
		returnValue = part1 + part2 + part3 + part4 + part5;		
        
        return returnValue;
    }

    private static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }
    
}