package com.JacksonMattJon.ui.util
{
	import flash.text.*;
	import flash.utils.*;
	import flash.filters.*;
	
	/**
	*   Utilities for dealing with strings
	*   @author Jackson Dunstan
	*/
	public class StringUtils
	{
		/**
		*	A utility function for capitalizing the first character of a string.
	    *	@param pInput	The string that needs the first letter capitalized.
		*	@return	String
		*/
		public static function capitalize(pInput: String): String
		{
			var capFirstLetter:String = (pInput.charAt(0)).toUpperCase();
			var rv:String = capFirstLetter + pInput.substring(1);
			return rv;
	    }
	    
		/**
		*   Check if a string is valid. It is valid if it is not null and has
		*   characters.
		*   @param str String to check
		*   @return If the string is valid
		*/
		public static function isValid(str:String): Boolean
		{
			return Boolean(str);
		}
	
		/**
	    *	This method is used to validate that a string is not an empty
	    *	string and does not contain the words "null" or "undefined" as
	    *	a result of an errant cast of an undefined variable into a String.
	    *	@param pInput	The string to validate as an empty string.
	    *	@return	If the given string is null, empty, "undefined", or "null"
	    */
	    public static function isEmptyString(pStr:String): Boolean
		{
			return !Boolean(pStr) || pStr == 'undefined' || pStr == 'null';
	    }
	    
		/**
		*   Synonmym for isEmptyString
		*   @deprecated
		*   @see isEmptyString
		*/
	    public static function isEmpty(pStr:String): Boolean
		{
	    	return isEmptyString(pStr);
	    }
		
		/**
		*   Convert a string of hexadecimal characters to an integer
		*   @deprecated
		*   @param str String to convert
		*   @return Integer value of the string
		*   @throws ArgumentError If the input string contains non-hex characters
		*/
		public static function hexStringToInt(str:String): int
		{
			return parseInt(str, 16);
		}
	    
	    /**
		*   Truncates the field's text until it fits into its size. If truncation
		*   occurs, "..." is added.
		*   @param field Field to truncate
		*   @param label Label to set to the field
		*/
		public static function truncateLabel(field:TextField, label:String): String
		{
			// The label isn't empty, use it
			if (label.length > 0)
			{
				field.htmlText = label;
			}
			// The label is empty, use what's already there
			else
			{
				label = field.htmlText;
			}
			
			// Get the field's size
			var fieldHeight:Number = field.height;
			var fieldWidth:Number = field.width; 
	
			// If there is a drop shadow filter, this affects the height
			var offset:Number = 0;
			if (field.filters.length > 0)
			{
				var filter:DropShadowFilter = field.filters[0];
				offset = filter.blurY;
				fieldHeight += offset;
			}
			
			// Truncate until the text fits or we don't have any more text to truncate
			field.autoSize = TextFieldAutoSize.LEFT;
			for (var len:Number = label.length; len > 1 && field.height > fieldHeight && field.width > fieldWidth; --len)
			{
				field.htmlText = label.slice(0, len) + "...";
			}
			field.autoSize = TextFieldAutoSize.NONE;
			field.height = fieldHeight - offset;
			
			return label;
		}
		
		/**
		*   Replace all occurances of a sub-string with another string
		*   @deprecated
		*   @param input String to replace in
		*   @param find Sub-string to replace
		*   @param replace String to replace with
		*   @return A new string with the replacement done
		*/
		public static function replace(input:String, find:String, replace:String): String
		{
			return input.split(find).join(replace);
		}
		
		/**
		*   Formats a time in seconds for display in the format MM:SS.
		*   @param seconds Number of seconds to format. This is clamped to zero.
		*/
		public static function formatTimeMMSS(seconds:Number): String
		{
			// Force into being a non-negative number
			if (isNaN(seconds) || seconds < 0)
			{
				seconds = 0;
			}
			
			var min:Number = Math.floor(seconds / 60);
			var sec:Number = seconds % 60; 
			
			return (min < 10 ? ("0" + min) : min)
			       + ":"
			       + ((sec < 10) ? ("0" + sec) : sec);
		}
		
		/**
		*   Check if a string is an e-mail address
		*   @param str String to check
		*   @return If the string is an e-mail address
		*/
		public static function isValidEmailAddress(str:String): Boolean
		{
		    return /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i.test(str);
		}
		
		/**
		*   Convert a string of hexadecimal characters to a number
		*   @deprecated
		*   @param str String to convert
		*   @return Number value of the string or NaN if the string contains
		*           non-hex characters
		*/
		public static function hexStringToNumber(str:String): Number
		{
			return parseInt(str, 16);
		}
		
		/**
		*   Inserts the pInsert string at the given position in pString
		*   @param pString the original string
		*   @param pInsert the string to insert into pString
		*   @param pPos the position at which to insert pInsert
		*   @return the new string
		*/
		public static function insert(pString:String, pInsert:String, pPos:int): String
		{
			return pString.slice(0, pPos) + pInsert + pString.slice(pPos, pString.length);
		}
		
		/**
		*   Replace a format string's values with values from a dictionary
		*   @param format Format string to replace values from
		*   @param dict Dictionary of corresponding values to replace with
		*   @param pattern (optional) Pattern to match values in the format string with
		*   @return The format string with replaced values
		*/
		public static function formatString(format:String, dict:Dictionary, pattern:RegExp = null): String 
		{
			if (pattern == null)
			{
				pattern = /\${(([a-z]|[A-Z]|_)(([a-z]|[A-Z]|_|\d)*))}/;
			}
			var regExpRes:Array;
			while ((regExpRes = pattern.exec(format)) != null)
			{
				format = format.replace(pattern, dict[regExpRes[1]]);
			}
			return format;
		}
	}
}
