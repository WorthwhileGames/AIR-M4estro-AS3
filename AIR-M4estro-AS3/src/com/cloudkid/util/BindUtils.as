package com.cloudkid.util
{
	import flash.display.*;
	import flash.utils.*;
	
	import com.cloudkid.util.Debug;
	
	public class BindUtils
	{
		/**
		*   Bind a movieclip content to a code object
		*   @param The display content to grab
		*   @param The code class to bind to
		*   @return Return the instance of the Class
		*/
		public static function bind(content:DisplayObject, codeClass:Class): *
		{
			var source:Sprite = Sprite(content);
			var obj:DisplayObject;
			var result:DisplayObjectContainer = new codeClass;
			var typeXML:XML = describeType(result);
			var type:String, paramClass:Class;
			var localVars:Dictionary = new Dictionary(true);
			result.name = content.name;
			for each(var node:XML in typeXML.variable)
			{
				type = String(node.@type);
				
				// Ignore variables that aren't inherited
				// part of the flash display
				// and are top-level objects (String, Array ,etc)
				//Debug.log(String(result) + node);
				//node.metadata is not present when verboseStackTrace is false, maybe other factors. But in short - build in release mode == no metadata
				if (/*node.metadata != undefined && */type.search(/^(flash|mx).*/) == -1 && type.search(/\./) > -1)
				{
					//Debug.log("Special variables : " + node.@name);
					localVars[String(node.@name)] = getDefinitionByName(type) as Class;
				}
			}
			while(source.numChildren > 0)
			{
				obj = source.getChildAt(0);
				//Debug.log(obj.name);
				if (result.hasOwnProperty(obj.name))
				{
					if (localVars[obj.name])
					{
						//Debug.log('Recursively bind ' + obj.name + " to " + localVars[obj.name]);
						var recursiveBind:DisplayObjectContainer = bind(obj, localVars[obj.name]);
						result[obj.name] = recursiveBind;
						
						recursiveBind.x = obj.x;
						recursiveBind.y = obj.y;
						recursiveBind.scaleX = obj.scaleX;
						recursiveBind.scaleY = obj.scaleY;
						recursiveBind.rotation = obj.rotation;
						
						source.removeChild(obj);
						result.addChild(recursiveBind);
					}
					else
					{
						//Debug.log("Adding variables " + obj.name + " to " + result);
						// For display object properties
						result[obj.name] = obj;
						result.addChild(obj);
					}
				}
				else
				{
					// For shapes and other non-class named properties
					result.addChild(obj);
				}
			}
			for(var key:Object in localVars)
			{
				delete localVars[key];
			}
			return result;
		}
	}
}