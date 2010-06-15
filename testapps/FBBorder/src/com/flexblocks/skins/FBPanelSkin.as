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

package com.flexblocks.skins {

	import com.flexblocks.borders.FBBorder;
	import com.flexblocks.fb_internal;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.EdgeMetrics;
	import mx.core.IContainer;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	use namespace fb_internal;
	
	// --------------------------------------------------------------------------------------------------
	// CLASS FBPanelSkin - This is a modified version of mx.skins.halo.PanelSkin
	// --------------------------------------------------------------------------------------------------
	
	/**
	 * The FBPanelSkin class defines the skin for the Panel, TitleWindow, and Alert components.
	 */
	 
	public class FBPanelSkin extends FBBorder {
		
		// Fill content hole flag 
		
		/**
		 * If set to "<code>true</code>" then the content hole will be filled with the background color; if set to "<code>false</code>", then the content hole will not be filled.
		 * 
		 * @default true
		 */
		
		protected var fillBgHole:Boolean = true;
		 
	    // Last measured height for the Panel ControlBar and header. Used by borderMetrics() to determine if the height of the ControlBar or header has changed.
	    
	    private var lastMeasuredHeaderHeight:Number = NaN;
	    private var lastMeasuredControlBarHeight:Number = NaN;

		// Border metrics

		/**
		 * Internal object that contains the thickness of each edge of the border
		 */
		
		protected var panelBorderMetrics:EdgeMetrics;
				
		// Static object used by the static function isPanel() to track whether or not the parent of FBPanelSkin is a Panel
		
		private static var panels:Object = new Object();
		
		// Shadow Type
		
		/**
		 * Determines what type of drop shadow to draw around the content area. The valid values are "<code>none</code>", "<code>drop</code>" and "<code>drop_delta</code>" 
		 * (see the documentation for the constants "<code>SHADOW_NONE</code>", "<code>SHADOW_DROP</code>" and "<code>SHADOW_DROP_DELTA</code>" for a description).
		 * 
		 * @default drop_delta
		 */
		
		protected var shadowType:String = SHADOW_DROP_DELTA;

		// Shadow type constants

		/**
		 * Do not draw a drop shadow around the content area.
		 */
		
		public static const SHADOW_NONE:String = "none";
		
		/**
		 * Draw a drop shadow around the content area. Uses the styles "<code>dropShadowColor</code>", "<code>shadowDistance</code>" and "<code>shadowDirection</code>" when drawing the shadow. Note that unlike
		 * "<code>SHADOW_DROP_DELTA</code>", the drop shadow drawn using "<code>SHADOW_DROP</code>" is the same regardless of the alpha value for the content area and the border area.
		 */
		
		public static const SHADOW_DROP:String = "drop";
		
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
		
		public static const SHADOW_DROP_DELTA:String = "drop_delta";
			
		// --------------------------------------------------------------------------------------------------
		// STATIC isPanel - Determine whether or not the parent is a Panel or extends a Panel
		//                  This method is called by borderMetrics() for ControlBar and header height calculations
		// --------------------------------------------------------------------------------------------------
 
  		static private function isPanel(parent:Object):Boolean {
 			
			// Get the qualified name of the parent
			
			var s:String = getQualifiedClassName(parent);
			
			// If the parent has previously been checked, return whether or not the parent is a Panel or extends a Panel
			
			if (panels[s] == 1) return true;	
			if (panels[s] == 0) return false;
	
			// If the parent is a panel, save flag and return true
			
			if (s == "mx.containers::Panel") {
				panels[s] = 1;
				return true;
			}
			
			// Get an XML object that describes the parent object
	
			var x:XML = describeType(parent);
			
			// Check to see if the parent's superclass is a Panel
			
			var xmllist:XMLList = x.extendsClass.(@type == "mx.containers::Panel");
			
			// If the XMLList is empty then the parent's superclass is not a Panel
			
			if (xmllist.length() == 0) {
				panels[s] = 0;
				return false;
			}
			
			// Else the parent's superclass is a Panel
			
			panels[s] = 1;
			return true;
		}
		
		// --------------------------------------------------------------------------------------------------
		// FBPanelSkin - Constructor 
		// --------------------------------------------------------------------------------------------------
		
	    /**
	     *  Constructor.
	     */
	     
	    public function FBPanelSkin() {
	        super();
	    }
	    
		// --------------------------------------------------------------------------------------------------
		// GET borderMetrics - Returns the thickness of the border edges (top, right, bottom, left thickness in pixels)
		// --------------------------------------------------------------------------------------------------

	    /**
	     * Returns the thickness of the border edges (top, bottom, left, right thickness in pixels). If the parent is a Panel then the borders will contain
	     * space for a ControlBar and/or a header (if a ContolBar or header is defined).  
	     */
	     
	    override public function get borderMetrics():EdgeMetrics {
	        
	        // If the parent is a Panel
	       
	        if (isPanel(this.parent)) {
	        	
		    	var controlBarHeight:Number = NaN;
		    	var headerHeight:Number = NaN;

	        	// Get the proxy to the ControlBar property which is protected in Panel and can't be accessed externally
	        	
	       		var controlBar:IUIComponent = Object(parent).mx_internal::_controlBar;

		        // If the parent contains a ControlBar and if the ControlBar is included in the layout (as opposed to being 
		        // positioned but ignored for the purpose of computing the position of the next child), then get the 
		        // explicitWidth if defined or measuredWidth if not.
		        
		        if (controlBar && controlBar.includeInLayout) controlBarHeight = controlBar.getExplicitOrMeasuredHeight();
	       		
	       		// Get header height from proxy to getHeaderHeight() which is protected in Panel and can't be accessed externally
	       		        
	        	headerHeight = Object(parent).mx_internal::getHeaderHeightProxy();
	
		        // If the ControlBar or the header either has or has previously had a height and the height has now changed, then re-calculate the metrics for the border
		        
		        if ((controlBarHeight != lastMeasuredControlBarHeight && !(isNaN(lastMeasuredControlBarHeight) && isNaN(controlBarHeight))) || (headerHeight != lastMeasuredHeaderHeight && !(isNaN(headerHeight) && isNaN(lastMeasuredHeaderHeight)))) { 
			
					// Save measured height values for comparison the next time this function is called
					
					lastMeasuredHeaderHeight = headerHeight;
			        lastMeasuredControlBarHeight = controlBarHeight;

					// Get border thickness styles (if defined)
			
			        var borderThickness:Number = getStyle("borderThickness");
			        var borderThicknessTop:Number = getStyle("borderThicknessTop");
			        var borderThicknessLeft:Number = getStyle("borderThicknessLeft");
			        var borderThicknessBottom:Number = getStyle("borderThicknessBottom");
			        var borderThicknessRight:Number = getStyle("borderThicknessRight");
			
					// Get the metrics from the FBBorder superclass
			       
			        var borderMetrics:EdgeMetrics = super.borderMetrics;
			        
			        // Initialize the new metrics
			        
			        panelBorderMetrics = new EdgeMetrics(0, 0, 0, 0);

			        // Add extra space to top, left and right border edges using border thickness styles
			        
			        panelBorderMetrics.left = borderMetrics.left + (isNaN(borderThicknessLeft) ? borderThickness : borderThicknessLeft);
			        panelBorderMetrics.top = borderMetrics.top + (isNaN(borderThicknessTop) ? borderThickness : borderThicknessTop);
			        panelBorderMetrics.right = borderMetrics.bottom + (isNaN(borderThicknessRight) ? borderThickness : borderThicknessRight);
			        
			        // The bottom border is a special case: If borderThicknessBottom is NaN, add space using borderThicknessLeft if there is no ControlBar or add space using borderThicknessTop if there is a ControlBar
			        
			        panelBorderMetrics.bottom = borderMetrics.bottom;
			        
			        if (isNaN(borderThicknessBottom)) { 
			            if (controlBar && !isNaN(borderThicknessTop)) panelBorderMetrics.bottom += borderThicknessTop;
						else panelBorderMetrics.bottom += (isNaN(borderThicknessLeft) ? borderThickness : borderThicknessLeft);
			        }
			        else panelBorderMetrics.bottom += borderThicknessBottom;

			        // If there is a header or a ControlBar, then increase the appropriate boarder to create room      
			        
			        if (!isNaN(headerHeight)) panelBorderMetrics.top += headerHeight;
			        if (!isNaN(controlBarHeight)) panelBorderMetrics.bottom += controlBarHeight;
				}
	        }
	        
	        return panelBorderMetrics;
	    }
	
		// --------------------------------------------------------------------------------------------------
		// styleChanged - Called when a style property is changed for FBPanelSkin
		// --------------------------------------------------------------------------------------------------

	    /**
	     *  Whenever a style change occurs, redraw this skin.
	     */
		 
		override public function styleChanged(prop:String):void {
			
			super.styleChanged(prop);
			
		 	// If a border style changes, clear the cached border metrics (they will be recalculated when borderMetrics is next called) and invalidate the display list	
	
			if (prop == null || prop == "styleName" || prop == "borderStyle" || prop == "borderThickness" || prop == "borderThicknessTop" || prop == "borderThicknessBottom" || prop == "borderThicknessLeft" || prop == "borderThicknessRight" || prop == "borderSides" ) {	    	
				panelBorderMetrics = null;
			}
			
			invalidateDisplayList();
		}
	
		// --------------------------------------------------------------------------------------------------
		// drawBorder - Draw the borders and the drop shadows for the panel
		//              The updateDisplayList method in FBBorder calls this method and the calls drawBackground (see below).
		// --------------------------------------------------------------------------------------------------

	    /**
	     *  @private
	     */
	     
	    override fb_internal function drawBorder(w:Number, h:Number):void {
	    	
	        // Call drawBorder in the superclass FBBorder (a border will not be drawn by the superclass for a "default" borderStyle)
	        
	        super.drawBorder(w, h);
	        	        
	        // If the border style is "default"
	        
	        if (getStyle("borderStyle") == "default") { 
	        	
	            // Get the size of the corner radius (radius is defined in the FBPanelSkin superclass)
	            
	            radius = getStyle("cornerRadius");
	            
	            // Determine if bottom corners are rounded (bottomRoundedCorners is defined in the FBPanelSkin superclass)
	            
	            bottomRoundedCorners = getStyle("roundedBottomCorners").toString().toLowerCase() == "true";
 
            	// If there are no rounded corners on the bottom then initialize the complex radius object else clear any previous corner radius data
            
           		if (!bottomRoundedCorners) radiusObj = new Object();
            	else radiusObj = null;	            
	            
	            // If rounded corners for the bottom are enabled then set the bottom corner radius, else clear the radius for the bottom corners
	            
	            var bottomCornerRadius:Number = bottomRoundedCorners ? radius : 0;	                                 
	    		
	    		// Draw a drop shadow around the Panel (drawDropShadow is a FBBorder method)
	            
	            drawDropShadow(0, 0, w, h, radius, radius, bottomCornerRadius, bottomCornerRadius);	            
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
	                           
            // Get the parent container
            
            var parentContainer:IContainer = this.parent as IContainer;
    
            // If there is a parent container
            
            if (parentContainer) {
            	
				// Get the viewMetrics for the container (The viewMetrics property includes possible scrollbars and non-content elements -- such as a Panel container's 
				// header area and the area for a ControlBar component -- in the calculations of the property values of the EdgeMetrics object)
            	
                var vMetrics:EdgeMetrics = parentContainer.viewMetrics;
    
                // Calculate the content area (backgroundHole, which is defined in the superclass FBPanelSkin)
                
                backgroundHole = {x:vMetrics.left, y:vMetrics.top, w: Math.max(0, w - vMetrics.left - vMetrics.right), h: Math.max(0, h - vMetrics.top - vMetrics.bottom), r:0};
    
                // If the content area has a valid width and height
                
                if (backgroundHole.w > 0 && backgroundHole.h > 0) {
                	
	            	var contentAlpha:Number = getStyle("backgroundAlpha");
	            	var backgroundAlpha:Number = getStyle("borderAlpha");	            	
				
                    // If the shadow type is to be drawn when alpha values for the border and content area differ then draw a shadow around the content
                    
                    if (shadowType == SHADOW_DROP_DELTA && contentAlpha != backgroundAlpha) drawDropShadow(backgroundHole.x, backgroundHole.y, backgroundHole.w, backgroundHole.h, 0, 0, 0, 0);	
	
					// If FBPanelSkin is subclassed, then the subclass can set fillBgHole to false if it wants to fill the background of the content hole

		            if (fillBgHole) {
		            	
			            // Get Graphics object for drawing the fill
	            
			            var g:Graphics = this.graphics;
	
	                    // Fill the content area with the background color
	                    
	                    g.beginFill(Number(backgroundColor), contentAlpha);
	                    g.drawRect(backgroundHole.x, backgroundHole.y, backgroundHole.w, backgroundHole.h);
	                    g.endFill();
	            	}
                }
            }
            
			// The Graphics object was set to use the backgroundColor to fill the content background so set backgroundColor
			// to borderColor so the border will be drawn using the correct color.
            
            this.backgroundColor = getStyle("borderColor");

            // FBBorder resets backgroundAlphaName to "backgroundAlpha" in updateDisplayList so set backgroundAlphaName to "borderAlpha" before calling the
            // superclass method drawBackground.
            
            this.backgroundAlphaName = "borderAlpha";

	        // Call the drawBackground method of the FBBorder superclass
	        
	        super.drawBackground(w, h);
	        
            // If there is a drop shadow active and if there is a background hole then draw a shadow around the content if the contentDropShadow is TRUE or is not defined
                    
			if (shadowType == SHADOW_DROP && backgroundHole.w > 0 && backgroundHole.h > 0) drawDropShadow(backgroundHole.x, backgroundHole.y, backgroundHole.w, backgroundHole.h, 0, 0, 0, 0);
	        	        
	        // If the headerColors style is not defined (i.e. Panel will not draw highlight) and the "default" borderStyle is in use, then draw a white edge highlight
	        
	        if (getStyle("headerColors") == null && getStyle("borderStyle") == "default") {
	        	
	            // Get the alpha values for the edge highlight
	            
	            var highlightAlphas:Array = getStyle("highlightAlphas");
	            var highlightAlpha:Number = highlightAlphas ? highlightAlphas[0] : 0.3;
	            
	            // Draw the white edge highlight
	            
	            drawRoundRect(0, 0, w, h, {tl: radius, tr: radius, bl: 0, br: 0}, 0xFFFFFF, highlightAlpha, null, GradientType.LINEAR, null, {x: 0, y: 1, w: w, h: h - 1, r: {tl: radius, tr: radius, bl: 0, br: 0}});
	        }  
	    }	    
	    
		// --------------------------------------------------------------------------------------------------
		// getBackgroundColorMetrics - Returns an EdgeMetrics object for use in drawing the background
		//                             (Called by the drawBackground method in the FBBorder superclass)
		// --------------------------------------------------------------------------------------------------

	    /**
	     *  @private
	     */

	    override fb_internal function getBackgroundColorMetrics():EdgeMetrics {	    	
	    	if (getStyle("borderStyle") == "default") return EdgeMetrics.EMPTY;
	        else return super.borderMetrics;
	    }
	}
}
