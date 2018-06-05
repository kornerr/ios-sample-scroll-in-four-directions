
import UIKit

// Internal logging function.
private func SAMPLE_VIEW_LOG(_ message: String)
{
    NSLog("SampleView \(message)")
}

private let SCREEN_WIDTH: CGFloat = 320

private let ITEM_HEIGHT: CGFloat = 200
private let ITEM_COLLAPSED_HEIGHT: CGFloat = ITEM_HEIGHT * 0.25
private let VIEWPORT_HEIGHT: CGFloat = 300
private let CONTENT_HEIGHT: CGFloat = VIEWPORT_HEIGHT + ITEM_COLLAPSED_HEIGHT * 6 // item's count - 1
private let PAGE_SCROLL_SIZE: CGFloat = ITEM_COLLAPSED_HEIGHT

/*

Proximity to size factor ratios:
* 0 -> 100%
* (0; 0.5) -> (100%; 25%)
* [0.5; Infinity) -> 25%

*/
private func sizeFactor(forCenterProximity proximity: CGFloat) -> CGFloat
{
    // 0 -> 1.
    if (proximity == 0)
    {
        return 1
    }
    // [0.5; Inifinity) -> 0.25.
    else if (proximity >= 0.5)
    {
        return 0.25
    }
    // (0; 0.5) -> (1; 0.25).
    // Convert proximity to (0; 1) range,
    // which can be treated as (0%; 100%) range.
    let unitProximity = proximity * 2.0
    let rangeSize = CGFloat(1.0) - 0.25 // = 0.75
    let factor = 1.0 - rangeSize * unitProximity
    return factor
}

class SampleView: UIView
{

    // MARK: - SETUP
    
    @IBOutlet private var gestureView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.setupScrolling()
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
        //self.setupContentView()
        //self.setupItemsLayoutFullHeight()
        self.setupItemsLayoutHalfHeight()
    }

    // MARK: - SCROLLING

    private var scrolling: Scrolling!
    private var scrollingBounds: ScrollingBounds!
    
    private func setupScrolling()
    {
        self.scrolling = Scrolling(trackedView: self.gestureView)
        self.scrollingBounds =
            ScrollingBounds(
                viewportHeight: VIEWPORT_HEIGHT,
                contentHeight: CONTENT_HEIGHT
            )
        self.scrolling.verticalReport = { [weak self] in
            guard let this = self else { return }
            this.scrollingBounds.setContentOffset(delta: this.scrolling.verticalDelta)
        }
        /*
        self.scrolling.verticalFinishReport = {
        }
        */
    }

    // MARK: - CONTENT VIEW

    private var contentView: UIView!

    private func setupContentView()
    {
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CONTENT_HEIGHT))
        self.contentView.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        self.itemsView.addSubview(self.contentView)

        // Scroll content view.
        self.scrollingBounds.contentOffsetReport = { [weak self] in
            guard let this = self else { return }
            //SAMPLE_VIEW_LOG("Content offset: '\(this.scrollingBounds.contentOffset)'")
            var frame = this.contentView.frame
            frame.origin.y = this.scrollingBounds.contentOffset
            this.contentView.frame = frame
        }
    }
    
    // MARK: - ITEMS

    private var items = [MasterItem]()

    func setItems(_ items: [MasterItem])
    {
        self.items = items
        // TODO Provide size from actual screen size (80% height, 100% width)
        let size = CGSize(width: SCREEN_WIDTH, height: ITEM_HEIGHT)
        self.generateItemViews(for: self.items, withSize: size)
        // TODO Display items in views
    }

    @IBOutlet private var itemsView: UIView!

    // MARK: - ITEM VIEWS
    
    private var itemViews = [UIView]()

    private func generateItemViews(for items: [MasterItem], withSize size: CGSize)
    {
        // Remove previously generated views.
        for view in self.itemViews
        {
            view.removeFromSuperview()
        }
        self.itemViews = []

        // Generate new views.
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        for item in items
        {
            let view = UIView(frame: frame)
            view.backgroundColor = item.color
            self.itemViews.append(view)
            self.itemsView.addSubview(view)
        }
    }

    // MARK: - FULL HEIGHT ITEMS LAYOUT

    private func setupItemsLayoutFullHeight()
    {
        // Scroll items.
        self.scrollingBounds.contentOffsetReport = { [weak self] in
            guard let this = self else { return }
            this.layItemsOutFullHeight()
        }
        // Perform the first laying out manually.
        self.layItemsOutFullHeight()
    }

    private func layItemsOutFullHeight()
    {
        let offset = self.scrollingBounds.contentOffset
        let position = -offset / PAGE_SCROLL_SIZE
        SAMPLE_VIEW_LOG("Position: '\(position)'")
        let pageId = Int(round(position))
        SAMPLE_VIEW_LOG("Page id: '\(pageId)'")

        let origin = VIEWPORT_HEIGHT / 2.0 - ITEM_HEIGHT / 2.0
        let height = ITEM_HEIGHT
        var y = origin - position * height

        for id in 0..<self.itemViews.count
        {
            let view = self.itemViews[id]

            // Resize and reposition view.
            var frame = view.frame
            // Set constant height.
            frame.size.height = height
            // Set view position.
            frame.origin.y = y
            view.frame = frame

            SAMPLE_VIEW_LOG("view id: '\(id)' frame: '\(frame)'")

            // Calculate position for the next view.
            y += height
        }
    }

    // MARK: - HALF HEIGHT ITEMS LAYOUT

    private func setupItemsLayoutHalfHeight()
    {
        // Scroll items.
        self.scrollingBounds.contentOffsetReport = { [weak self] in
            guard let this = self else { return }
            this.layItemsOutHalfHeight()
        }
        // Perform the first laying out manually.
        self.layItemsOutHalfHeight()
    }

    private func layItemsOutHalfHeight()
    {
        var logMessage = ""
        let offset = self.scrollingBounds.contentOffset
        logMessage += "Offset: '\(-offset)' "
        logMessage += "PageScrollSize: '\(PAGE_SCROLL_SIZE)' "
        let position = -offset / PAGE_SCROLL_SIZE
        logMessage += "Position: '\(position)' "
        let pageId = Int(round(position))
        logMessage += "Page id: '\(pageId)' "

        SAMPLE_VIEW_LOG(logMessage)

        /*
        let origin = VIEWPORT_HEIGHT / 2.0 - ITEM_HEIGHT / 2.0
        // The first item is central at the moment.
        var y = origin - position * ITEM_HEIGHT

        for id in 0..<self.itemViews.count
        {
            let view = self.itemViews[id]
            var frame = view.frame

            // Height.
            let proximity = abs(CGFloat(id) - position)
            let factor = sizeFactor(forCenterProximity: proximity)
            SAMPLE_VIEW_LOG("view id: '\(id)' center proximity: '\(proximity)' size factor: '\(factor)'")
            // Set height based on proximity to the center.
            frame.size.height = ITEM_HEIGHT * factor

            // Position.
            frame.origin.y = y
            y += frame.size.height

            // Apply changes.
            view.frame = frame

            SAMPLE_VIEW_LOG("view id: '\(id)' frame: '\(frame)'")
        }
        */
    }

}

