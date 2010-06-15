/*

The MIT License

Copyright (c) 2008 Paul Whitelock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package com.flexblocks.skins {
	
	import com.flexblocks.fb_internal;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.BitmapAsset;
	import mx.core.IContainer;	
		
	use namespace fb_internal;
	
	// Styles
	
	/**
	 * Defines the alpha level for the content area. Values of less than 1.0 allow whatever is behind the panel to be seen though the panel's content area. 
	 * Note that content drawn within the Panel's content area may prevent the transparency from being seen (for example, a "<code>backgroundImage</code>" might completely
	 * fill the content area and mask the transparency). The default value is 1.0. 
	 */
	
	[Style(name="contentBackgroundAlpha", type="Number", inherit="yes")]
	
	/**
	 * Defines the type of shadow drawn for the content area. Possible values are "<code>none</code>", "<code>drop</code>", "<code>drop_delta</code>" 
	 * and "<code>inner</code>". The default value is "<code>drop_delta</code>". 
	 * 
	 * <p>See the documentation for the constants "<code>SHADOW_NONE</code>", "<code>SHADOW_DROP</code>", "<code>SHADOW_DROP_DELTA</code>" 
	 * and "<code>SHADOW_INNER</code>" for a description of the shadow types available.</p>
	 */
	
	[Style(name="shadowType", type="String", enumeration="none, drop, drop_delta, inner", inherit="yes")]
	
	/**
	 * Defines the direction that a shadow is cast. Possible values are "<code>left</code>", "<code>center</code>" and "<code>right</code>". The default is "<code>center</code>".
	 */
	
	// [Style(name="shadowDirection", type="String", enumeration="left, center, right", inherit="yes")]	

	/**
	 * Determines whether a shadow is drawn for the content area. If set to "<code>false</code>" then the current shadow type is saved and "<code>shadowType</code>" is set to "<code>none</code>".
	 * If set to "<code>true</code>" then the last active shadow type is restored. The default value is "<code>true</code>".
	 */
	
	// [Style(name="dropShadowEnabled", type="Boolean", inherit="yes")]	

	/**
	 * If the currently active shadow type is an inner shadow, then this style sets the strength of the inner shadow. The default is "<code>0.6</code>".
	 */
	
	[Style(name="contentInnerShadowStrength", type="Number", inherit="yes")]	

	/**
	 * If the currently active shadow type is an inner shadow, this style sets the amount of blur used to drawn the inner shadow. The default is "<code>5</code>".
	 */
	
	[Style(name="contentInnerShadowBlur", type="Number", inherit="yes")]	

	/**
	 * If the currently active shadow type is an inner shadow, then this style sets the distance of the inner shadow. The default is "<code>3</code>".
	 */
	
	[Style(name="contentInnerShadowDistance", type="Number", enumeration="none,drop,drop_delta,inner", inherit="yes")]	

	/**
	 * If a gradient is defined for the content area (i.e., "<code>contentGradientColors</code>" is assigned and no "<code>contentBackgroundTile</code>" is active), then
	 * this style sets the type of gradient that is drawn. Possible values are "<code>linear</code>" and "<code>radial</code>". The default value is "<code>linear</code>".
	 */
	
	[Style(name="contentGradientType", type="String", enumeration="linear, radial", inherit="yes")]	

	/**
	 * Defines the colors used to draw a gradient in the background of the content area. The array may be of any length, though there must be a corresponding gradient ratio for each
	 * gradient color (see the "<code>contentGradientRatios</code>" style). Note that if a background image tile has been set using the "<code>contentBackgroundTile</code>"
	 * style, then the image tile will take precedence and the gradient will not be drawn.
	 */
	
	[Style(name="contentGradientColors", type="Array", arrayType="uint", format="Color", inherit="yes")]	

	/**
	 * Defines the ratio (or emphasis) for each gradient color in the color array that was defined using the "<code>contentGradientColors</code>" style. There must be one ratio for each color.
	 * Acceptable values range from "<code>0</code>" to "<code>255</code>".
	 */
	
	[Style(name="contentGradientRatios", type="Array", arrayType="Number", inherit="yes")]	

	/**
	 * If a linear gradient is defined for the content area (i.e., "<code>contentGradientColors</code>" is assigned and no "<code>contentBackgroundTile</code>" is active), then
	 * this style sets the angle of rotation used to draw the gradient. Note that this style has no effect for radial gradients. The default value is "<code>90</code>".
	 */
	
	[Style(name="contentGradientRotation", type="Array", arrayType="Number", inherit="yes")]	

	/**
	 * A reference to an embedded JPEG, GIF or PNG image file that is tiled to fill the background of the content area. Note that if a gradient is also defined then 
	 * then the image tile will take precedence and the gradient will not be drawn.
	 */
	
	[Style(name="contentBackgroundTile", type="Class", inherit="yes")]
	
	// --------------------------------------------------------------------------------------------------
	// CLASS FBBgPanelSkin
	// --------------------------------------------------------------------------------------------------	
	
 	/**
	 * The FBBgPanelSkin class defines an enhanced skin for the Panel, TitleWindow, and Alert components.
	 * 
	 * The skin adds additional styles to FBPanelSkin that include an inner drop shadow for the content area, a gradient background for the content area and
	 * a tiled image background for the content area.
	 */

	public class FBPanelBgSkin extends com.flexblocks.skins.FBPanelSkin {
		
		/**
		 * Set to "<code>true</code>" when all styles have been parsed for the first time.
		 */

		protected var stylesInitialized:Boolean = false;
		
		/**
		 * The rendered background for the content area. The "<code>renderedBackground</code>" consists of an inner shadow, a tiled image background with or without an inner shaodw, 
		 * or a gradient background with an inner shadow. 
		 */
		
		protected var renderedBackground:BitmapData = null;	

		private var contentBackgroundAlpha:Number = 1.0;
		private var backgroundTile:BitmapData = null;
		private var gradientType:String = GradientType.LINEAR;
		private var gradientRotation:Number = 90.0;
		private var innerShadowStrength:Number = 0.6;
		private var innerShadowDistance:Number = 3;
		private var innerShadowBlur:Number = 5;
		private var shadowAngle:Number = 90;
		private var lastW:Number = 0;
		private var lastH:Number = 0;
		private var lastShadowType:String = SHADOW_DROP_DELTA;
		
		[ArrayElementType("uint")]
		private var backgroundGradient:Array;
		
		[ArrayElementType("uint")]
		private var backgroundGradientRatios:Array;
		
		// Shadow type constants

		/**
		 * Do not draw a drop shadow around the content area.
		 */

		public static const SHADOW_NONE:String = FBPanelSkin.SHADOW_NONE;

		/**
		 * Draw a drop shadow around the content area. Uses the styles "<code>dropShadowColor</code>", "<code>shadowDistance</code>" and "<code>shadowDirection</code>" when drawing the shadow. Note that unlike
		 * "<code>SHADOW_DROP_DELTA</code>", the drop shadow drawn using "<code>SHADOW_DROP</code>" is the same regardless of the alpha value for the content area and the border area.
		 */

		public static const SHADOW_DROP:String = FBPanelSkin.SHADOW_DROP;

		/**
		 * Draw a drop shadow around the content area when alpha values differ. Uses the styles "<code>dropShadowColor</code>", "<code>shadowDistance</code>" and "<code>shadowDirection</code>" when drawing the shadow. 
		 * 
		 * <p>This is the Adobe method of drawing a drop shadow and it results in a lighter drop shadow than using "<code>SHADOW_DROP</code>". Also, if the alpha value for the content area
		 * matches the alpha value of the border area, then a drop shadow will NOT be drawn (a drop shadow is only drawn if there is a difference between the two alpha values). 
		 * An instance when this is useful is when an Alert is displayed: by default a drop shadow will not be drawn around the content area of the Alert panel if "<code>SHADOW_DROP_DELTA"<code> is used. 
		 * If "<code>SHADOW_DROP"<code> is used, then a drop shadow will be drawn in the Alert panel.</p> 
		 * 
		 * <p>If you would like to maintain a similar look and feel for the drop shadow between panels that use this skin and panels that use the stock Adobe skin, assign the "<code>SHADOW_DROP</code>" constant value
		 * to the "<code>shadowType</code>" property.
		 */

		public static const SHADOW_DROP_DELTA:String = FBPanelSkin.SHADOW_DROP_DELTA;

		/**
		 * Draw an inner shadow around the content area. Uses the styles "<code>dropShadowColor</code>", "<code>shadowDirection</code>", "<code>contentInnerShadowDistance</code>", 
		 * "<code>contentInnerShadowBlur</code>", "<code>contentInnerShadowStrength</code>" when drawing the shadow.
		 */

		public static const SHADOW_INNER:String = "inner";

		// --------------------------------------------------------------------------------------------------
		// FBPanelSkin - Constructor 
		// --------------------------------------------------------------------------------------------------
		
	    /**
	     *  Constructor.
	     */

		public function FBPanelBgSkin() {
			
			// Initialize the superclass FBPanelSkin
			
			super();
			
			// Make sure the superclass does not fill the background of the content hole
			
			fillBgHole = false;
		}
		
		// --------------------------------------------------------------------------------------------------
		// styleChanged 
		// --------------------------------------------------------------------------------------------------

	    /**
	     *  Whenever a style change occurs, redraw this skin.
	     */

		override public function styleChanged(styleProp:String):void {
			
			// Call the superclass method
			
			super.styleChanged(styleProp);
			
			// If the passed style property is not null, process the style property
			
			if (styleProp != null) parseStyle(styleProp);
		}		

		// --------------------------------------------------------------------------------------------------
		// parseStyle - Processes data for a specific style property, or if NULL is passed as the style property then initialize all style properties
		// --------------------------------------------------------------------------------------------------	

		private function parseStyle(styleProp:String = null):void {

			var doRender:Boolean = false;
			var doCheck:Boolean = true;
			
			// Alpha for Content Area Background
			
			if (styleProp == null || (doCheck && styleProp == "contentBackgroundAlpha")) {
				var contentBackgroundAlphaStyle:Object = getStyle("contentBackgroundAlpha");
				if (contentBackgroundAlphaStyle is Number && Number(contentBackgroundAlphaStyle) != contentBackgroundAlpha) {
					contentBackgroundAlpha = Number(contentBackgroundAlphaStyle);
					doRender = true;
				}
				doCheck = false;
			}

			// Shadow type
			
			if (styleProp == null || (doCheck && styleProp == "shadowType")) {
				var shadowTypeStyle:Object = getStyle("shadowType");
				if (shadowTypeStyle is String && String(shadowTypeStyle).toLowerCase() != shadowType) {
					shadowType = String(shadowTypeStyle).toLowerCase();
					lastShadowType = shadowType;
					if (styleProp == null && shadowType != FBPanelBgSkin.SHADOW_DROP_DELTA) invalidateDisplayList();
					doRender = true;
				}
				doCheck = false; 
			}
			
			// Shadow direction
			
			if (styleProp == null || (doCheck && styleProp == "shadowDirection")) {
				var shadowDirectionStyle:Object = getStyle("shadowDirection");
				if (shadowDirectionStyle is String) {
					var newShadowAngle:Number = getDropShadowAngle(innerShadowDistance, String(shadowDirectionStyle));
					if (newShadowAngle != shadowAngle) {
						shadowAngle = newShadowAngle;
						doRender = true;
					}
				}
				doCheck = false;
			}
						
			// Shadow enabled state
			
			if (styleProp == null || (doCheck && styleProp == "dropShadowEnabled")) {			
				if (getStyle("dropShadowEnabled").toString().toLowerCase() == "false") {
					lastShadowType = shadowType;
					shadowType = SHADOW_NONE;
				}
				else shadowType = lastShadowType;
				doRender = true;
				doCheck = false;
			}			
						
			// Strength of inner shadow
			
			if (styleProp == null || (doCheck && styleProp == "contentInnerShadowStrength")) {
				var innerShadowStrengthStyle:Object = getStyle("contentInnerShadowStrength");
				if (innerShadowStrengthStyle is Number && Number(innerShadowStrengthStyle) != innerShadowStrength) {
					innerShadowStrength = Number(innerShadowStrengthStyle);
					doRender = true;
				}
				doCheck = false;
			}
			
			// Inner shadow blur amount
			
			if (styleProp == null || (doCheck && styleProp == "contentInnerShadowBlur")) {
				var innerShadowBlurStyle:Object = getStyle("contentInnerShadowBlur");
				if (innerShadowBlurStyle is Number && Number(innerShadowBlurStyle) != innerShadowBlur) {
					innerShadowBlur = Number(innerShadowBlurStyle);
					doRender = true;
				}
				doCheck = false;
			}			
			
			// Inner shadow distance
			
			if (styleProp == null || (doCheck && styleProp == "contentInnerShadowDistance")) {
				var innerShadowDistanceStyle:Object = getStyle("contentInnerShadowDistance");
				if (innerShadowDistanceStyle is Number && Number(innerShadowDistanceStyle) != innerShadowDistance) {
					innerShadowDistance = Number(innerShadowDistanceStyle);
					doRender = true;
				}
				doCheck = false;
			}			
			
			// Gradient type for content area background
			
			if (styleProp == null || (doCheck && styleProp == "contentGradientType")) {
				var contentGradientTypeStyle:Object = getStyle("contentGradientType");				
				if ((contentGradientTypeStyle is String) && String(contentGradientTypeStyle).toLowerCase() == GradientType.RADIAL) gradientType = GradientType.RADIAL;
				else gradientType = GradientType.LINEAR;
				doRender = true;
				doCheck = false;
			}
						
			// Gradient colors for content area background
			
			if (styleProp == null || (doCheck && styleProp == "contentGradientColors")) {
				var contentGradientStyle:Object = getStyle("contentGradientColors");				
				if (contentGradientStyle is Array) backgroundGradient = contentGradientStyle as Array;
				else backgroundGradient = null;
				doRender = true;
				doCheck = false;
			}
			
			// Gradient ratios for content area background
			
			if (styleProp == null || (doCheck && styleProp == "contentGradientRatios")) {
				var contentGradientRatiosStyle:Object = getStyle("contentGradientRatios");				
				if (contentGradientRatiosStyle is Array) backgroundGradientRatios = contentGradientRatiosStyle as Array;
				else backgroundGradientRatios = null;
				doRender = true;
				doCheck = false;
			}			
			
			// Gradient rotation angle
			
			if (styleProp == null || (doCheck && styleProp == "contentGradientRotation")) {
				var contentGradientAngleStyle:Object = getStyle("contentGradientRotation");
				if (contentGradientAngleStyle is Number && Number(contentGradientAngleStyle) != gradientRotation) {
					gradientRotation = Number(contentGradientAngleStyle);
					doRender = true;
				}
				doCheck = false;
			}			
						
			// Tile Image for Content Area Background
			
			if (styleProp == null || (doCheck && styleProp == "contentBackgroundTile")) {
				
				//  If a background tile image already exists, dispose of the image data and set the flag to re-render
					
				if (backgroundTile != null) {
					backgroundTile.dispose();
					doRender = true;
				}
				backgroundTile = null;

				// Check for the contentBackgroundTile style
				
				var backgroundTileStyle:Object = getStyle("contentBackgroundTile");
			
				// If there is a tile image
				
				if (backgroundTileStyle is Class) {
															
					// Cast the image as a Class
					
					var contentBackgroundTile:Class = Class(backgroundTileStyle);
				
					// Get the bitmap data for the image, testing to make sure that the imageClass is not a symbol in a SWF (which will not work)
				
					if (contentBackgroundTile != null) {
		            	try {
		                	var background:BitmapAsset = BitmapAsset(new contentBackgroundTile());
		                   	backgroundTile = background.bitmapData;
		                } catch (e:TypeError) {
		                    throw new Error("Style property \"contentBackgroundTile\" is not a valid image class");
		                } finally {}
					}
					
					doRender = true;
				}
				doCheck = false;
			}
			
			// If the display should be re-rendered then set the lastW to zero so that the background will be re-generated
			
			if (styleProp != null && (doRender || (doCheck && (styleProp == "dropShadowColor" || styleProp == "backgroundColor" || styleProp == "backgroundImage")))) {
				lastW = 0;
				invalidateDisplayList();
			}						
		}
		
		// --------------------------------------------------------------------------------------------------
		// renderBackground - Render a bitmap background for the content area
		// --------------------------------------------------------------------------------------------------

	    /**
	     * Renders the content background into a BitmapData object. This is done to improve efficiency so that the background does not need to be re-rendered unnecessarily.
	     * The content background will be re-rendered whenever a style changes or whenever the size of the content area changes.
	     */

		protected function renderBackground(totalWidth:Number, totalHeight:Number, contentTop:Number, contentLeft:Number, contentW:Number, contentH:Number):void {
			
			// If styles have not yet been initialized, parse data for all style properties
			
			if (!stylesInitialized) {
				parseStyle();
				stylesInitialized = true;
			}
			
			// Clear previously rendered background (if any)
			
			if (renderedBackground != null) {
				renderedBackground.dispose();
				renderedBackground = null;	
			}

			// Draw an inner shadow in the content area?

			var contentInnerShadow:Boolean = shadowType == SHADOW_INNER;
						
			// If there is a background tile create the tiled background image for the content area
				
			if (backgroundTile != null) {	
			
				// Create the background BitmapData and a BitMapData object for the alpha
				
				var fillBackground:BitmapData = new BitmapData(contentW, contentH, true);
				
				// If there is no inner shadow, create an alpha map to set the background transparency
				
				if (!contentInnerShadow) var alphaMap:BitmapData = new BitmapData(contentW, contentH, true, Math.round(contentBackgroundAlpha * 255) << 24);

				// Fill the content area with the tile image
				
				var vTiles:int = Math.ceil(contentH / backgroundTile.height);
				var hTiles:int = Math.ceil(contentW / backgroundTile.width);
				var tileLocation:Point = new Point(0, 0);

				for (var i:int = 0; i < vTiles; i++) { 
					
					for (var j:int = 0; j < hTiles; j++) {
						fillBackground.copyPixels(backgroundTile, backgroundTile.rect, tileLocation, contentInnerShadow ? null : alphaMap);
						tileLocation.x += backgroundTile.width;									
					}
					
					tileLocation.x = 0;
					tileLocation.y += backgroundTile.height - 1;
				}
								
				// Draw inner shadow if requested or if no inner shadow then dispose of the alpha map used to set the background transparency
				
				if (contentInnerShadow) drawInnerShadow(fillBackground, contentBackgroundAlpha);
				else {
					alphaMap.dispose();
					alphaMap = null;
				}			
			}
					
			// Else there is no tile image so check for gradient data and/or inner shadow
			
			else {
				
				// Draw a gradient background?
				
				if (backgroundGradient) {
					
					// Make sure the length of the gradient ratios array exists and matches the length of the gradient colors array
					
					if (!backgroundGradientRatios) backgroundGradientRatios = new Array();
					
					if (backgroundGradientRatios.length < backgroundGradient.length) { 
						while (backgroundGradientRatios.length < backgroundGradient.length) backgroundGradientRatios.push(0xFF);
					}
					else if (backgroundGradientRatios.length > backgroundGradient.length) {
						backgroundGradientRatios.splice(backgroundGradient.length - backgroundGradientRatios.length, backgroundGradientRatios.length - backgroundGradient.length);	
					}			
				}

				// If there is a contentInnerShadow then create a background image for the content area
				
				if (contentInnerShadow) {
			
					// Create the BitMap for the background image
						
					fillBackground = new BitmapData(contentW, contentH, true);

					// If a background gradient is to be drawn
				
					if (backgroundGradient) {
						
						// The gradient must be drawn into a Sprite before the BitMapData can be created
						
						var gradientSprite:Sprite = new Sprite();
						gradientSprite.width = contentW;
						gradientSprite.height = contentH;
						
						// Create gradient alpha array to match length of gradient color array
						
						var backgroundGradientAlphas:Array = new Array(backgroundGradient.length);
						for (i = 0; i < backgroundGradientAlphas.length; i++) backgroundGradientAlphas[i] = 1.0;
						
						// Draw the gradient in the Sprite
						
						var gsg:Graphics = gradientSprite.graphics;
						var gradientMatrix:Matrix = new Matrix();
						gradientMatrix.createGradientBox(contentW, contentH, gradientRotation * (Math.PI / 180), 0, 0);
						
						gsg.beginGradientFill(gradientType, backgroundGradient, backgroundGradientAlphas, backgroundGradientRatios, gradientMatrix);
						gsg.drawRect(0, 0, contentW, contentH);
						gsg.endFill();
						
						// Copy the gradient data to an intermediate BitmapData
						
						var spriteBackground:BitmapData = new BitmapData(contentW, contentH, true);
						spriteBackground.draw(gradientSprite);
						
						// Draw with proper alpha
						
						var spriteBackgroundAlpha:BitmapData = new BitmapData(contentW, contentH, true);
						fillBackground.copyPixels(spriteBackground, spriteBackground.rect, new Point(0, 0), spriteBackgroundAlpha);
						
						// Done with Sprite and BitmapData objects
						
						gradientSprite = null;
						spriteBackground.dispose();
						spriteBackground = null;
						spriteBackgroundAlpha.dispose();
						spriteBackgroundAlpha = null;
					}
					
					// Else the background is a solid color
					
					else {
						
						// Get the background color from the superclass
						
						var bgColor:uint = uint(getBackgroundColor());						
												
						// Fill the content area with the solid color
												
						fillBackground.fillRect(fillBackground.rect, bgColor | 0xFF000000);						
					}
					
					// Render the inner shadow and set proper transparency
					
					drawInnerShadow(fillBackground, contentBackgroundAlpha);
				}
			}
			
			// If a background image has been created
			
			if (fillBackground != null) {
				
				// Create the final BitmapData object
				
				renderedBackground = new BitmapData(totalWidth, totalHeight, true);

				// Position the tiled background in the location of the content area
				
				renderedBackground.copyPixels(fillBackground, fillBackground.rect, new Point(contentLeft, contentTop));

				// The fillBackground BitmapData is no longer needed
				
				fillBackground.dispose();
				fillBackground = null;						
			}
			
       		// Update dimension of last drawn background
					
			lastW = contentW;
			lastH = contentH;
		}
		
		// --------------------------------------------------------------------------------------------------
		// drawInnerShadow - Draws an inner shadow in a BitMapData object and sets the transparency level for the image
		// --------------------------------------------------------------------------------------------------

	    /**
	     * Draws an inner shadow into a BitmapData object and optionally sets the alpha level for the resulting image. If an alpha value is not specified the 
	     * alpha value defaults to "<code>1</code>" (opaque).
	     */
	     
	    protected function drawInnerShadow(image:BitmapData, imageAlpha:Number = 1):void {
	    	
	    	// Create a new BitmapData object for the inner shadow image
	    	
	    	var shadowImage:BitmapData = new BitmapData(image.width, image.height);

			// Render the inner shadow
			
			try {
				var dropShadowColor:uint = getStyle("dropShadowColor");
				var innerShadow:DropShadowFilter = new DropShadowFilter(innerShadowDistance, shadowAngle, dropShadowColor, 1, innerShadowBlur, innerShadowBlur, innerShadowStrength, BitmapFilterQuality.LOW, true);
				shadowImage.applyFilter(image, image.rect, new Point(0, 0), innerShadow);
			}
			catch (error:Error) {
				shadowImage = null;
			}
			
			// If the inner shadow was successfully rendered
			
			if (shadowImage) {
			
				// Set proper alpha for image
				
				var alphaMap:BitmapData = new BitmapData(image.width, image.height, true, uint(Math.round(imageAlpha * 255)) << 24);
				image.copyPixels(shadowImage, shadowImage.rect, new Point(0, 0), alphaMap);
	
				// Dispose of shadowImage BitmapData and alphaMap BitmapData
				
				shadowImage.dispose();
				shadowImage = null;		
				alphaMap.dispose();
				alphaMap = null;
			}
	    }
	    
		// --------------------------------------------------------------------------------------------------
		// drawBackground - Draws the panel background (the content area is filled by drawBorder) and a white edge highlight (if "default" style and there are no headerColors defined)
		//                  This method is called by updateDisplayList in FBBorder after it has called drawBorder (see above).
		// --------------------------------------------------------------------------------------------------

	    /**
	     *  @private
	     */
	     
	    override fb_internal function drawBackground(w:Number, h:Number):void {
	                           
	        // Call the drawBackground method of the FBPanelSkin superclass
	        
	        super.drawBackground(w, h);

            // Get the parent container
            
            var parentContainer:IContainer = this.parent as IContainer;
    
            // If there is a parent container
            
            if (parentContainer) {
            	
                // If the content area has a valid width and height
                
                if (backgroundHole.w > 0 && backgroundHole.h > 0) {
                	
                	// If the content area has changed dimension (or if a style property was changed thereby setting lastW to zero), render the content area background if necessary
                	
                	if (backgroundHole.w != lastW || backgroundHole.h != lastH) renderBackground(w, h, backgroundHole.y, backgroundHole.x, backgroundHole.w, backgroundHole.h);                	
    
		            // Get Graphics object for drawing the fill
            
		            var g:Graphics = this.graphics;

					// If a rendered background was created then fill the content area with the rendered background
					
					if (renderedBackground != null) g.beginBitmapFill(renderedBackground, null, false);
					
					// Else if no rendered background was created and there is background gradient data, fill the content background with the gradient
					
					else if (backgroundGradient) {

						// Create gradient alpha array to match length of gradient color array
						
						var backgroundGradientAlphas:Array = new Array(backgroundGradient.length);
						for (var i:int = 0; i < backgroundGradientAlphas.length; i++) backgroundGradientAlphas[i] = contentBackgroundAlpha;

						// Initialize the gradient fill
						
						var gradientMatrix:Matrix = new Matrix();
						gradientMatrix.createGradientBox(backgroundHole.w, backgroundHole.h, gradientRotation * (Math.PI / 180), 0, backgroundHole.y);
						g.beginGradientFill(gradientType, backgroundGradient, backgroundGradientAlphas, backgroundGradientRatios, gradientMatrix);
					}
					
					// Else fill the content background with a solid color
					
					else {
						
	            		// Get the solid color for the content area background
	            		
	            		var contentBgColor:uint = uint(getBackgroundColor());
	            		
	            		// If a backgroundImage is specified, then the alpha value for the backgroundColor is contentBackgroundAlpha;
	            		// otherwise the standard backgroundAlpha style property is used for the alpha value for the background color
	            		
	            		var solidAlpha:Number = contentBackgroundAlpha;
						var backgroundImageStyle:Object = getStyle("backgroundImage");
						if (!(backgroundImageStyle is Class)) {
							var backgroundAlphaStyle:Object = getStyle("backgroundAlpha");
							if (backgroundAlphaStyle is Number) solidAlpha = Number(backgroundAlphaStyle);
						}
						
						// Initialize the solid fill
						
						g.beginFill(contentBgColor, solidAlpha);
					}
					
					// Fill the content area
					
					g.drawRect(backgroundHole.x, backgroundHole.y, backgroundHole.w, backgroundHole.h);
					g.endFill();								
                 }
            }           
	    }
	}
}