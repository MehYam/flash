/*

Portions of this code are coyrighted by Adobe 

ADOBE SYSTEMS INCORPORATED
Copyright 2003-2007 Adobe Systems Incorporated
All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file
in accordance with the terms of the license agreement accompanying it.

Code that is not under Adobe's copyright is licensed under the MIT License

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

package com.flexblocks.borders {

	import com.flexblocks.fb_internal;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.BitmapAsset;
	import mx.core.EdgeMetrics;
	import mx.core.IUIComponent;
	import mx.graphics.RectangularDropShadow;
	import mx.skins.RectangularBorder;
	import mx.styles.IStyleClient;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	import mx.utils.GraphicsUtil;	
	
	use namespace fb_internal;

 	/**
	 * A reference to an embedded JPEG, GIF or PNG image file. The image is tiled to fill the background area.
	 */
	
	[Style(name="borderTile", type="Class", inherit="yes")]

	// --------------------------------------------------------------------------------------------------
	// CLASS FBBorder - This is a modified version of mx.skins.halo.HaloBorder 
	// --------------------------------------------------------------------------------------------------

	/**
	 * Draws borders, either rectangular or non-rectangular, around UIComponents.
	 */
	 
	public class FBBorder extends RectangularBorder	{
		
		/**
		 * @private
		 */		

		fb_internal var backgroundColor:Object;	

		/**
		 * @private
		 */		

		fb_internal var backgroundAlphaName:String; 

		/**
		 * @private
		 */		

		fb_internal var backgroundHole:Object;

		/**
		 * @private
		 */		

		fb_internal var bottomRoundedCorners:Boolean;

		/**
		 * @private
		 */		

		fb_internal var radius:Number;

		/**
		 * @private
		 */		

		fb_internal var radiusObj:Object;

		// Thickness of each edge of the border
		
		/**
		 * @private
		 */		
		
		protected var _borderMetrics:EdgeMetrics;

		// Reference to the object used to cast a drop shadow (See the drawDropShadow() method for details)
		  
		private var dropShadow:RectangularDropShadow;
		
		// Indicates whether an initial check for a borderTile style has been performed
		
		private var backgroundTileCheck:Boolean = false;
		
		// BitmapData for the background image tile (if any)
		
		private var panelBackgroundTile:BitmapData = null;
		
		// Flag to indicate that the borderTile image has been removed and that the image data may be disposed of
		
		private var removeBackgroundTile:Boolean = false;

		// --------------------------------------------------------------------------------------------------
		// FBBorder - Constructor
		// --------------------------------------------------------------------------------------------------
	
		/**
		 * Constructor.
		 */
		 
		public function FBBorder() {			
			super(); 	
		}
		
		// --------------------------------------------------------------------------------------------------
		// GET borderMetrics - Returns the thickness of the border edges (top, bottom, left, right thickness in pixels)
		// --------------------------------------------------------------------------------------------------	
	
		/**
		 * The thickness of the border edges.
		 */
		 
		override public function get borderMetrics():EdgeMetrics {		
			
			// If the border metrics have not yet been calculated
			
			if (!_borderMetrics) {
				
				// Get the border style name
						
				var borderStyle:String = getStyle("borderStyle");
		
		 		// default 
		 		// alert
		 		
		 		if (borderStyle == "default" || borderStyle == "alert") {
		 			
		 			// No border for default or alert
		 			
		 			_borderMetrics = new EdgeMetrics(0, 0, 0, 0);
		 		}
		 		
				// controlBar
				// applicationControlBar
				
				else if (borderStyle == "controlBar" || borderStyle == "applicationControlBar") {
					
					// 1 pixel border for controlBar and applicationControlBar
					
					_borderMetrics = new EdgeMetrics(1, 1, 1, 1);
				}
			
				// solid
				
				else if (borderStyle == "solid") {
					
					// Get the borderThickness style property (set to zero if the property is undefined)
					
					var borderThickness:Number = getStyle("borderThickness");					
					if (isNaN(borderThickness)) borderThickness = 0;
					
					// Create the EdgeMetrics object using the borderThickness style
		
					_borderMetrics = new EdgeMetrics(borderThickness, borderThickness, borderThickness, borderThickness);
						
					// Check to see what sides are active for the border
					
					var borderSides:String = getStyle("borderSides");
								
					// If all four sides are not active
					
					if (borderSides != "left top right bottom") {
						
						// Adjust metrics based on which sides we have	
									
						if (borderSides.indexOf("left") == -1) _borderMetrics.left = 0;					
						if (borderSides.indexOf("top") == -1) _borderMetrics.top = 0;					
						if (borderSides.indexOf("right") == -1) _borderMetrics.right = 0;					
						if (borderSides.indexOf("bottom") == -1)_borderMetrics.bottom = 0;
					}
				}
				
				// inset
				// outset
				// dropdown
				// comboNonEdit
				// menuBorder
				// [other]
				
				else {
					
					// Border thickness of 2 for inset, outset, dropdown and comboNonEdit
									
					if (borderStyle == "inset" || borderStyle == "outset" || borderStyle == "dropdown" || borderStyle == "comboNonEdit")  borderThickness = 2;
					
					// Border thickness of 1 for menuBorder
					
					else if (borderStyle == "menuBorder") borderThickness = 1;
					
					// Any other style set a border thickness of zero
					
					else borderThickness = 0;
								
					// Create the EdgeMetrics using the border thickness
					
					_borderMetrics = new EdgeMetrics(borderThickness, borderThickness, borderThickness, borderThickness);
				}
			}
			
			return _borderMetrics;
		}
	
		// --------------------------------------------------------------------------------------------------
		// styleChanged - Called when a style property is changed for FBBorder
		// --------------------------------------------------------------------------------------------------
	
		/**
		 * Whenever any style changes, redraw this skin.
		 */
		 
		override public function styleChanged(styleProp:String):void {
			
			// If the image for the background tile has changed, load the new tile bitmap
			
			if (styleProp == "borderTile" || (panelBackgroundTile != null && styleProp == "borderAlpha")) getBackgroundTile();

			// Else if a border style has changed, clear the cached border metrics (they will be recalculated when borderMetrics is next called) and invalidate the display list
			
			else if (styleProp == null || styleProp == "styleName" || styleProp == "borderStyle" || styleProp == "borderThickness" ||	styleProp == "borderSides") _borderMetrics = null;	
					
			// Redraw
			
			invalidateDisplayList();
		}
	
		// --------------------------------------------------------------------------------------------------
		// getBackgroundTile - Checks to see if the borderTile style property has been defined, and if so retrieves the data for the tile image
		// --------------------------------------------------------------------------------------------------
	
		private function getBackgroundTile():void {
						
			var tempPanelBackgroundTile:BitmapData = null;
			
			// Check to see if a borderTile style has been defined
			
			var backgroundTileStyle:Object = getStyle("borderTile");		
		
			// If there is a tile image
			
			if (backgroundTileStyle is Class) {
														
				// Cast the image as a Class
				
				var backgroundTileImage:Class = Class(backgroundTileStyle);
			
				// Get the bitmap data for the image, testing to make sure that the imageClass is not a symbol in a SWF (which will not work)
			
				if (backgroundTileImage != null) {
					
	            	try {
	            		
	            		// Get the alpha
	            		
	            		var alpha:Number = getStyle(backgroundAlphaName);
	            		
	                	// Get the BitmapData for the tile image
	                	
	                	var background:BitmapAsset = BitmapAsset(new backgroundTileImage());
	                	var backgroundTileBMD:BitmapData = background.bitmapData;
	                	
	                	// Create a BitmapData object for the image with the correct level of transparency
	                	
	                	tempPanelBackgroundTile = new BitmapData(backgroundTileBMD.width, backgroundTileBMD.height, true);
	            		var alphaMap:BitmapData = new BitmapData(backgroundTileBMD.width, backgroundTileBMD.height, true, Math.round(alpha * 255) << 24);
	            		tempPanelBackgroundTile.copyPixels(backgroundTileBMD, backgroundTileBMD.rect, new Point(0, 0), alphaMap);
	            		
	            		// Get rid of BitmapData objects that are no longer needed
	            		
	            		backgroundTileBMD.dispose();
	            		alphaMap.dispose();	            		
	                } 
	                catch (e:TypeError) {
	                    throw new Error("Style property \"borderTile\" is not a valid image class");
	                } finally {}
				}
			}
			
			// If a background tile was created then assign the tile to be drawn; otherwise, if an image already exists set a flag so that the image is 
			// disposed of the next time that the background is drawn
			
			if (tempPanelBackgroundTile) {
				panelBackgroundTile = tempPanelBackgroundTile;
				removeBackgroundTile = false;
			}
			else removeBackgroundTile = true;
		}

		// --------------------------------------------------------------------------------------------------
		// updateDisplayList - Draw the border and background
		// --------------------------------------------------------------------------------------------------

		/**
		 * Programmatically draws the border and background graphics for this skin.
		 */
		 
		override protected function updateDisplayList(w:Number, h:Number):void {
			
			// If the width and height are numbers
			
			if (!(isNaN(w) || isNaN(h))) {
				
				// Call the superclass method
				
				super.updateDisplayList(w, h);
		
				// Store background color in an object so that null (no background color) is distinct from black (0x000000)
				
				backgroundColor = getBackgroundColor();
				
				// Initialize variables to default values prior to drawing
				
				bottomRoundedCorners = false;	
				backgroundAlphaName = "backgroundAlpha";
				backgroundHole = null;
				radius = 0;
				radiusObj = null;
				
				// Draw the border and the background
		
				drawBorder(w, h);		
				drawBackground(w, h);
			}	
		}
	
		// --------------------------------------------------------------------------------------------------
		// drawBorder - Draw the border
		// --------------------------------------------------------------------------------------------------
	
		/**
		 * @private
		 */
		 
		fb_internal function drawBorder(w:Number, h:Number):void {
			
			// Variables used for more than one border style
			
			var borderColor:uint;
			var borderColorDrk1:Number
			var borderColorDrk2:Number
			var borderColorLt1:Number	
			var borderInnerColor:Object;

			// Get the style of border to draw
			
			var borderStyle:String = getStyle("borderStyle");
								
			// Get the Graphics object for drawing
			
			var g:Graphics = this.graphics;
			
			// Clear previous drawing
			
			g.clear();
			
			// If a border style is assigned
	
			if (borderStyle) {
				
				// Get alpha value(s) for border highlight gradient (can be null, Number or Array)
				
				var highlightAlphas:Array = getStyle("highlightAlphas");	
				
				// Draw the border based on the border style				
				
				switch (borderStyle) {
					
					// "none" - Do not draw a border

					case "none":
					
						break;
	
					// "inset" border - Used for text input & numeric stepper
					
					case "inset":
					
						// Get the color for the border and create colors variations for a 3D inset border

						borderColor = getStyle("borderColor");
							
						borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -40);
						borderColorDrk2 = ColorUtil.adjustBrightness2(borderColor, +25);
						borderColorLt1 = ColorUtil.adjustBrightness2(borderColor, +40);							
						
						if (borderInnerColor === null || borderInnerColor === "") borderInnerColor = borderColor;
						else borderInnerColor = backgroundColor;
						
						// Draw the 3D inset border
						
						draw3dBorder(borderColorDrk2, borderColorDrk1, borderColorLt1, Number(borderInnerColor), Number(borderInnerColor), Number(borderInnerColor));
						
						break;
	
					// "outset" border
					
					case "outset":

						// Get the color for the border and create colors variations for a 3D outset border
						
						borderColor = getStyle("borderColor");
								
						borderColorDrk1 = ColorUtil.adjustBrightness2(borderColor, -40);
						borderColorDrk2 = ColorUtil.adjustBrightness2(borderColor, -25);
						borderColorLt1 = ColorUtil.adjustBrightness2(borderColor, +40);
						
						if (borderInnerColor === null || borderInnerColor === "") borderInnerColor = borderColor;
						else borderInnerColor = backgroundColor;
						
						// Draw the 3D outset border
						
						draw3dBorder(borderColorDrk2, borderColorLt1, borderColorDrk1, Number(borderInnerColor), Number(borderInnerColor), Number(borderInnerColor));
						
						break;
	
					// "alert" and "default" borders - Borders are not drawn in Flex 3 for "alert" and "default"
					
					case "alert":
					case "default":

						break;
	
					// "dropdown" border - Not used?
					
					case "dropdown":
							
						// Draw a drop shadow around the dropDown border
						
						drawDropShadow(0, 0, w, h, 4, 0, 0, 4);
	
						// Frame
						
						drawRoundRect(0, 0, w, h, {tl: 4, tr: 0, br: 0, bl: 4}, 0x4D555E, 1);
	
						// Gradient
						
						drawRoundRect(0, 0, w, h, {tl: 4, tr: 0, br: 0, bl: 4}, [0xFFFFFF, 0xFFFFFF], [0.7, 0], verticalGradientMatrix(0, 0, w, h)); 
						
						// Button top highlight edge
						
						drawRoundRect(1, 1, w - 1, h - 2, {tl: 3, tr: 0, br: 0, bl: 3}, 0xFFFFFF, 1); 
						
						// Button face
						
						drawRoundRect(1, 2, w - 1, h - 3, {tl: 3, tr: 0, br: 0, bl: 3}, [0xEEEEEE, 0xFFFFFF], 1, verticalGradientMatrix(0, 0, w - 1, h - 3)); 
	
						// The dropdownBorderColor is currently only used when displaying an error state
						
						var dropdownBorderColor:uint = getStyle("dropdownBorderColor");

						// If the dropdownBorderColor is defined
						
						if (!isNaN(dropdownBorderColor)) {
							
							// Combo background in error state
							
							drawRoundRect(0, 0, w + 1, h, {tl: 4, tr: 0, br: 0, bl: 4}, dropdownBorderColor, 0.5);
							
							// Button top highlight edge
							
							drawRoundRect(1, 1, w - 1, h - 2, {tl: 3, tr: 0, br: 0, bl: 3}, 0xFFFFFF, 1); 
							
							// Button face
							
							drawRoundRect(1, 2, w - 1, h - 3, {tl: 3, tr: 0, br: 0, bl: 3}, [0xEEEEEE, 0xFFFFFF], 1, verticalGradientMatrix(0, 0, w - 1, h - 3)); 
						}
						
						// Make sure the border isn't filled later
						
						backgroundColor = null;
						
						break;
	
					// "menuBorder" border
					
					case "menuBorder":
					
						// Get the color for the border
						
						borderColor = getStyle("borderColor");
						
						// Draw a 1-pixel border and a drop shadow
						
						drawRoundRect(0, 0, w, h, 0, borderColor, 1);
						drawDropShadow(1, 1, w - 2, h - 2, 0, 0, 0, 0);
						
						break;
					
					// "comboNonEdit" border - A border is not drawn for this border type
					
					case "comboNonEdit":

						break;
						
					// "controlBar" border
					
					case "controlBar":

						// Only draw if the width and height is greater than zero
						
						if (w > 0 && h > 0) {
							
							var footerColors:Array = getStyle("footerColors");	
															
							// Show chrome?
							
							if (footerColors != null) {								
								
								var borderAlpha:Number = getStyle("borderAlpha");

								g.lineStyle(0, footerColors.length > 0 ? footerColors[1] : footerColors[0], borderAlpha);
								g.moveTo(0, 0);
								g.lineTo(w, 0);
								g.lineStyle(0, 0, 0);
		
								// The cornerRadius is defined on parent container
								
								if (parent && parent.parent && parent.parent is IStyleClient) {
									radius = IStyleClient(parent.parent).getStyle("cornerRadius"); 
									borderAlpha = IStyleClient(parent.parent).getStyle("borderAlpha"); 
								}
								
								if (isNaN(radius)) radius = 0;
		
								// If the parent has square bottom corners then use square corners here
								
								if (IStyleClient(parent.parent).getStyle("roundedBottomCorners").toString().toLowerCase() != "true") radius = 0;
								
								// Draw background
								
								drawRoundRect(0, 1, w, h - 1, {tl: 0, tr: 0, bl: radius, br: radius}, footerColors, borderAlpha, verticalGradientMatrix(0, 0, w, h));
		
								// Draw gradient fill if more than one footer color defined and the colors are different
								
								if (footerColors.length > 1 && footerColors[0] != footerColors[1]) {
									
									drawRoundRect(0, 1, w, h - 1, {tl: 0, tr: 0, bl: radius, br: radius}, [0xFFFFFF, 0xFFFFFF], highlightAlphas, verticalGradientMatrix(0, 0, w, h));
		
									drawRoundRect(1, 2, w - 2, h - 3, {tl: 0, tr: 0, bl: radius - 1, br: radius - 1}, footerColors, borderAlpha, verticalGradientMatrix(0, 0, w, h));
								}
							}
						}
	
						// Don't draw the background color later
						
						backgroundColor = null;
						
						break;
						
					// "applicationControlBar" border
					
					case "applicationControlBar":

						// Get styles
						
						var backgroundAlpha:Number = getStyle("backgroundAlpha");
						var fillColors:Array = getStyle("fillColors");
						var fillAlphas:Array = getStyle("fillAlphas");
						var docked:Boolean = getStyle("docked");
							
						radius = getStyle("cornerRadius");
						if (!radius) radius = 0;
	
						// Draw drop shadow behind bar
	
						drawDropShadow(0, 1, w, h - 1, radius, radius, radius, radius);
	
						// Draw bar background if a background color is defined
						
						var backgroundColorNum:uint = uint(backgroundColor);
						if (backgroundColor !== null && StyleManager.isValidStyleValue(backgroundColor)) drawRoundRect(0, 1, w, h - 1, radius, backgroundColorNum, backgroundAlpha, verticalGradientMatrix(0, 0, w, h));
	
						// Bar surface
						
						drawRoundRect(0, 1, w, h - 1, radius, fillColors, fillAlphas, verticalGradientMatrix(0, 0, w, h));
						
						// Bar highlight
									
						drawRoundRect(0, 1, w, (h / 2) - 1, {tl: radius, tr: radius, bl: 0, br: 0}, [0xFFFFFF, 0xFFFFFF], highlightAlphas, verticalGradientMatrix(0, 0, w, h / 2 - 1));
	
						// Bar edge
						
						drawRoundRect(0, 1, w, h - 1, {tl: radius, tr: radius, bl: 0, br: 0}, 0xFFFFFF, 0.3, null, GradientType.LINEAR, null, {x: 0, y: 2, w: w, h: h - 2, r: {tl: radius, tr: radius, bl: 0, br: 0}});
	
						// Don't draw the background color later

						backgroundColor = null;
	
						break;

					// default - "solid" border or a null borderStyle	
	
					default: 

						// Get styles
						
						var borderThickness:Number = getStyle("borderThickness");
						var borderSides:String = getStyle("borderSides").toLowerCase();;						
						borderColor = getStyle("borderColor");								
						radius = getStyle("cornerRadius");						
						bottomRoundedCorners = getStyle("roundedBottomCorners").toString().toLowerCase() == "true";
						
						// Calculate the content area (the "hole")
						
						var holeRadius:Number = Math.max(radius - borderThickness, 0);							
						var hole:Object = {x: borderThickness, y: borderThickness, w: w - borderThickness * 2, h: h - borderThickness * 2, r: holeRadius};
						
						// Create object for border radii and hole radii (used by drawRoundrect). If the bottom corners are not rounded, the border radius and hole radius 
						// objects will have their bottom-left and bottom-right radii set to zero.
						
						radiusObj = {tl: radius, tr: radius, bl: bottomRoundedCorners ? radius : 0, br: bottomRoundedCorners ? radius : 0};
						hole.r = {tl: holeRadius, tr: holeRadius, bl: bottomRoundedCorners ? holeRadius : 0, br: bottomRoundedCorners ? holeRadius : 0};
						
						// If there are not borders on all four sides
						
						if (borderSides != "left top right bottom") {
							
							// At least one side does not have a border
							
							var bHasAllSides:Boolean = false;
							
							// No left border 
							
							if (borderSides.indexOf("left") == -1) {
								hole.x = 0;
								hole.w += borderThickness;
								hole.r.tl = 0;
								hole.r.bl = 0;
								radiusObj.tl = 0;
								radiusObj.bl = 0;								
							}
							
							// No top border
							
							if (borderSides.indexOf("top") == -1) {
								hole.y = 0;
								hole.h += borderThickness;
								hole.r.tl = 0;
								hole.r.tr = 0;
								radiusObj.tl = 0;
								radiusObj.tr = 0;
							}
							
							// No right border
							
							if (borderSides.indexOf("right") == -1) {
								hole.w += borderThickness;
								hole.r.tr = 0;
								hole.r.br = 0;
								radiusObj.tr = 0;
								radiusObj.br = 0;
							}
							
							// No bottom border
							
							if (borderSides.indexOf("bottom") == -1) {
								hole.h += borderThickness;
								hole.r.bl = 0;
								hole.r.br = 0;
								radiusObj.bl = 0;
								radiusObj.br = 0;
							}
						}
						
						// Else all four sides have borders
						
						else bHasAllSides = true;
	
						// If all four sides have borders and none of the borders have rounded corners then draw a plain rectangular border
						
						if (radius == 0 && bHasAllSides) {
							
							// Draw a drop shadow
							
							drawDropShadow(0, 0, w, h, 0, 0, 0, 0);
						
							// Draw the rectangular border 
							
							g.beginFill(borderColor);
							g.drawRect(0, 0, w, h);
							g.endFill();
							
							// Fill the content area with the backgroundColor
							
							g.beginFill(uint(backgroundColor));
							g.drawRect(hole.x, hole.y, hole.w, hole.h);
							g.endFill();
							
							// No need to draw background later
							
							backgroundColor = null;
						}
						
						// Else at least one corner is rounded
						
						else {
							
							// Draw a drop shadow with rounder corners
							
							drawDropShadow(0, 0, w, h, radiusObj.tl, radiusObj.tr, radiusObj.br, radiusObj.bl);
						
							// Draw the border with rounded corners
							
							drawRoundRect(0, 0, w, h, radiusObj, borderColor, 1, null, null, null, hole);
							
							// Reset radius here so background drawing is correct (radius should not exceed borderThickness)
							
							radiusObj.tl = Math.max(radius - borderThickness, 0);
							radiusObj.tr = Math.max(radius - borderThickness, 0);
							radiusObj.bl = bottomRoundedCorners ? Math.max(radius - borderThickness, 0) : 0;
							radiusObj.br = bottomRoundedCorners ? Math.max(radius - borderThickness, 0) : 0;
						}
						
						break;		
				} 
			}
		}
		
		// --------------------------------------------------------------------------------------------------
		// draw3dBorder - Draw a border with "3D" shading
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function draw3dBorder(outsideSidesColor:Number, outsideTopColor:Number, outsideBtmColor:Number, insideTopColor:Number, insideBtmColor:Number, insideSidesColor:Number):void {
						
			// Draw a drop shadow for the component
			
			drawDropShadow(0, 0, width, height, 0, 0, 0, 0);
			
			// Get the Graphics object for drawing
			
			var g:Graphics = this.graphics;
			
			// Outside sides
			
			g.beginFill(outsideSidesColor);
			g.drawRect(0, 0, width, height);
			g.drawRect(1, 0, width - 2, height);
			g.endFill();
			
			// Outside top
			
			g.beginFill(outsideTopColor);
			g.drawRect(1, 0, width - 2, 1);
			g.endFill();
			
			// Outside bottom
			
			g.beginFill(outsideBtmColor);
			g.drawRect(1, height - 1, width - 2, 1);
			g.endFill();
			
			// Inside top
			
			g.beginFill(insideTopColor);
			g.drawRect(1, 1, width - 2, 1);
			g.endFill();
			
			// Inside bottom
			
			g.beginFill(insideBtmColor);
			g.drawRect(1, height - 2, width - 2, 1);
			g.endFill();
			
			// Inside sides
			
			g.beginFill(insideSidesColor);
			g.drawRect(1, 2, width - 2, height - 4);
			g.drawRect(2, 2, width - 4, height - 4);
			g.endFill();
		}
	
		// --------------------------------------------------------------------------------------------------
		// drawBackground - Fill the content area
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function drawBackground(w:Number, h:Number):void {
			
			// If there is a background color defined or if there is a mouse shield (i.e., if there is a mouse event listener on this view), then draw the background
			
			if ((backgroundColor !== null && backgroundColor !== "") || getStyle("mouseShield") || getStyle("mouseShieldChildren")) {
				
				// Initialize background color
				
				var backgroundColorNbr:Number = Number(backgroundColor);
				var alpha:Number = getStyle(backgroundAlphaName);
				
				if (isNaN(backgroundColorNbr) || backgroundColor === "" || backgroundColor === null) {
					alpha = 0;
					backgroundColorNbr = 0xFFFFFF;
				}
								
				// If an initial check for a background tile has not yet been performed, check to see if the borderTile style has been defined
				
				if (!backgroundTileCheck) {
					getBackgroundTile();
					backgroundTileCheck = true;
				}
				
				// If the backgroundStyle was changed and the background image tile was removed, then dispose of the image data
				
				if (removeBackgroundTile && panelBackgroundTile) {
					removeBackgroundTile = false;
					panelBackgroundTile.dispose();
					panelBackgroundTile = null;
				}			
		
				// Get metrics for border width
				
				var bMetrics:EdgeMetrics = getBackgroundColorMetrics();
				
				// Get Graphics object for drawing
				
				var g:Graphics = graphics;
	
				// If the radius is non-zero or if a subclass has defined backgroundHole use drawRoundRect() to fill the background
				
				if (radius != 0 || backgroundHole) {
						
					// If a object with radius values for each corner is defined
					
					if (radiusObj) {
						
						// If the bottom corners are rounded the all radii will be equal; otherwise the radii for the bottom corners are set to zero
						
						var bottomRadius:Number = bottomRoundedCorners ? radius : 0;	
						radiusObj = {tl: radius, tr: radius, bl: bottomRadius, br: bottomRadius};
	
						// If there is a tile image, then draw the background with the appropriate corners rounded using the image
						
						if (panelBackgroundTile) drawBitmapRoundRect(bMetrics.left, bMetrics.top, width - (bMetrics.left + bMetrics.right), height - (bMetrics.top + bMetrics.bottom),	radiusObj,	panelBackgroundTile, backgroundHole);
												
						// Else draw the solid color background with the appropriate corners rounded
						
						else drawRoundRect(bMetrics.left, bMetrics.top, width - (bMetrics.left + bMetrics.right), height - (bMetrics.top + bMetrics.bottom), radiusObj, backgroundColorNbr, alpha, null, GradientType.LINEAR, null,	backgroundHole);
					}
					
					// Else draw backround with all four rounded corners having the same radius
					
					else {
						
						// If there is a tile image, then draw the background using the image
						
						if (panelBackgroundTile) drawBitmapRoundRect(bMetrics.left, bMetrics.top, width - (bMetrics.left + bMetrics.right), height - (bMetrics.top + bMetrics.bottom),	radius,	panelBackgroundTile, backgroundHole);
						
						// Else draw a solid color background
						
						else drawRoundRect(bMetrics.left, bMetrics.top, width - (bMetrics.left + bMetrics.right), height - (bMetrics.top + bMetrics.bottom),	radius,	backgroundColorNbr, alpha, null,	GradientType.LINEAR, null,	backgroundHole);
					}
				}
				
				// Else the corner radius is zero and there is no backgroundHole defined by a sublass, so perform a standard rectangular fill
				
				else {
										
					// If there is a tile image, then begin the background fill using the image; else, use a solid color fill
					
					if (panelBackgroundTile) g.beginBitmapFill(panelBackgroundTile);
					else g.beginFill(backgroundColorNbr, alpha);
					
					// Draw the background
					
					g.drawRect(bMetrics.left, bMetrics.top, w - bMetrics.right - bMetrics.left, h - bMetrics.bottom - bMetrics.top);
					
					// End the fill
					
					g.endFill();
				}
			}
		}
		
		// --------------------------------------------------------------------------------------------------
		// drawBitmapRoundRect - Draw a rectangle with one of more rounded corners using a bitmap fill
		// --------------------------------------------------------------------------------------------------

		/**
		 * Draws a rectangle with one of more rounded corners using a bitmap fill into this skin's Graphics object.
		 */

		protected function drawBitmapRoundRect(x:Number, y:Number, width:Number, height:Number, cornerRadius:Object, bm:BitmapData, hole:Object = null):void	{
			
			var g:Graphics = this.graphics;
	
			// Proceed if there is a valid width, height and BitmapData object
	
			if (width > 0 && height > 0 && bm != null) {
		
				// Begin the fill using the bitmap
		
				g.beginBitmapFill(bm);
	
				// If the corner radius is the same for all corners
				
				if (cornerRadius is Number) {
					var ellipseSize:Number = Number(cornerRadius) * 2;
					g.drawRoundRect(x, y, width, height, ellipseSize, ellipseSize);
				}
				
				// Else at least one corner radius is different
				
				else GraphicsUtil.drawRoundRectComplex(g, x, y, width, height, cornerRadius.tl, cornerRadius.tr, cornerRadius.bl, cornerRadius.br);
		
				// Carve a rectangular hole out of the middle of the rounded rectangle
				
				if (hole) {
					
					// Get radius for the hole corners
					
					var holeR:Object = hole.r;
					
					// If the corner radius is the same for all corners
					
					if (holeR is Number) {
						ellipseSize = Number(holeR) * 2;
						g.drawRoundRect(hole.x, hole.y, hole.w, hole.h,	ellipseSize, ellipseSize);
					}
					
					// Else at least one corner radius is different
					
					else GraphicsUtil.drawRoundRectComplex(g, hole.x, hole.y, hole.w, hole.h, holeR.tl, holeR.tr, holeR.bl, holeR.br);	
				}
		
				// End the bitmap fill
				
				g.endFill();
			}
		}			
	
		// --------------------------------------------------------------------------------------------------
		// drawDropShadow - Apply a drop shadow using a bitmap filter
		//                  Bitmap filters are slow, and their slowness is proportional to the number of pixels being filtered.
		//                  Instead, we'll use the RectangularDropShadow which is optimized for a rectangularly-shaped objects whose edges fall on pixel boundaries.
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function drawDropShadow(x:Number, y:Number, width:Number, height:Number, tlRadius:Number, trRadius:Number, brRadius:Number, blRadius:Number):void {
			
			// If a drop shadow should be drawn

			if (getStyle("dropShadowEnabled").toString().toLowerCase() == "true" && width > 0 && height > 0) {
	
				// Get and distance and direction for the shadow
				
				var distance:Number = Math.abs(getStyle("shadowDistance"));
				var direction:String = getStyle("shadowDirection");
				
				// Calculate the angle for the shadow
		
				if (getStyle("borderStyle") == "applicationControlBar") {
					var angle:Number = Boolean(getStyle("docked")) ? 90 : getDropShadowAngle(distance, direction);
				}
				else {
					angle = getDropShadowAngle(distance, direction);
					distance += 2;
				}
				
				// Create the RectangularDropShadow object 
				
				if (!dropShadow) dropShadow = new RectangularDropShadow();
		
				// Set drop shadow properties
				
				dropShadow.distance = distance;
				dropShadow.angle = angle;
				dropShadow.color = getStyle("dropShadowColor");
				dropShadow.alpha = 0.4;
		
				dropShadow.tlRadius = tlRadius;
				dropShadow.trRadius = trRadius;
				dropShadow.blRadius = blRadius;
				dropShadow.brRadius = brRadius;
		
				// Draw the drop shadow
				
				dropShadow.drawShadow(this.graphics, x, y, width, height);
			}
		}
	
		// --------------------------------------------------------------------------------------------------
		// getDropShadowAngle - Convert the value of the shadowDirection property ("left", "right" or "center") into a shadow angle
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function getDropShadowAngle(distance:Number, direction:String):Number {			
			if (direction == "left") return distance >= 0 ? 135 : 225;	
			if (direction == "right") return distance >= 0 ? 45 : 315;
			return distance >= 0 ? 90 : 270;
		}
	
		// --------------------------------------------------------------------------------------------------
		// getBackgroundColor - Returns the backgorundColor or the backgroundDisabledColor (if the parent component is disabled)
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function getBackgroundColor():Object {
			
			// Get the parent component
			
			var parentUIComponent:IUIComponent = this.parent as IUIComponent;
			
			// If the parent component is not enabled, then return backgroundDisabledColor
			
			if (parentUIComponent && !parentUIComponent.enabled) {
				var color:Object = getStyle("backgroundDisabledColor");
				if (color !== null && StyleManager.isValidStyleValue(color)) return color;
			}
			
			// Else return the current backgroundColor
	
			return getStyle("backgroundColor");
		}
		
		// --------------------------------------------------------------------------------------------------
		// getBackgroundColorMetrics - Returns an EdgeMetrics object for use in drawing the background
		// --------------------------------------------------------------------------------------------------

		/**
		 * @private
		 */
		 
		fb_internal function getBackgroundColorMetrics():EdgeMetrics {
			return borderMetrics;
		}
	}
}
