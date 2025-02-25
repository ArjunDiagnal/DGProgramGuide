# DGProgramGuide Integration

![Image](https://github.com/user-attachments/assets/f59a92ab-97a5-4fdb-80a5-487fa26244b3)

![Image](https://github.com/user-attachments/assets/8b31e6e1-cad0-4563-b4ec-f1412f2737a0)

![Image](https://github.com/user-attachments/assets/d9405512-b16a-473c-828a-e79b8accf76f)

This repository demonstrates how to integrate the `DGProgramGuide` framework into a view controller and display a TV guide.

## 📌 Prerequisites

- **iOS 13+**
- **Xcode 14+**
- **Swift 5+**
- **Swift Package Manager (SPM) (if applicable for DGProgramGuide installation)**

## 🛠 Installation

### Using Swift Package Manager (SPM):
1. Open your Xcode project.
2. Go to **File** > **Swift Packages** > **Add Package Dependency**.
3. Enter the repository URL for `DGProgramGuide`.
4. Choose **Version**, **Branch**, or **Commit** as needed.
5. Click **Next** and **Finish**.

## 📖 Usage

### 1️⃣ Import the Framework

```swift
import DGProgramGuide
```

### 2️⃣ Setup the TV Guide

Add the following function inside your **ViewController** to initialize and display the `DGGuide` view.

```swift
func setupTVGuide() {
    
    UIConfig.shared.backgroundColor = .blue /// Theme for guide views
    
    let epgView = DGGuide()
    epgView.backgroundColor = .black /// Background colour set to black by default
    epgView.translatesAutoresizingMaskIntoConstraints = false
    epgView.delegate = self
    epgView.parentController = self
    
    view.addSubview(epgView)
    
    /// Constraint to set tv guide to match parent view
    NSLayoutConstraint.activate([
        epgView.topAnchor.constraint(equalTo: view.topAnchor),
        epgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        epgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        epgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}
```

### 3️⃣ Convert Model Data

Ensure that your model conversion functions are implemented as follows:

```swift
extension EPGViewController {

    func convertImages(_ images: [DummyImage]?) -> [DGProgramGuide.DummyImage] {
        guard let images = images else { return [] }
        return images.map { image in
            DGProgramGuide.DummyImage(
                url: image.url,
                width: image.width,
                height: image.height
            )
        }
    }

    func convertThumbImages(_ images: TvGuideThumbnail?) -> DGProgramGuide.TvGuideThumbnail? {
        guard let images = images else { return nil }
        return DGProgramGuide.TvGuideThumbnail(
            url: images.url,
            width: images.width,
            height: images.height
        )
    }

    func convertProgram(_ program: TVGuideProgram?) -> DGProgramGuide.TVGuideProgram? {
        guard let program = program else { return nil }
        return DGProgramGuide.TVGuideProgram(
            id: program.id,
            title: program.title,
            description: program.description,
            image: convertImages(program.image)
        )
    }
}
```

```swift
    func convertListing(_ listing: create_d2c.Listings) -> DGProgramGuide.Listings {
        return DGProgramGuide.Listings(
            listingId: listing.listingId,
            paId: listing.paId,
            title: listing.title,
            description: listing.description,
            startTime: listing.startTime,
            endTime: listing.endTime,
            seasonNumber: listing.seasonNumber,
            programType: listing.programType,
            listingGuid: listing.listingGuid,
            program: convertProgram(listing.program),
            dummyLiveEvent: listing.dummyLiveEvent
        )
    }

    func convertModel(_ entries: [TVGuideEntries]?) -> [GuideEntries]? {
        guard let entries = entries else { return nil }
        return entries.map { entry in
            return GuideEntries(
                id: entry.id,
                guid: entry.guid,
                updated: entry.updated,
                title: entry.title,
                callSign: entry.callSign,
                listings: entry.listings?.map { convertListing($0) },
                thumbnail: convertThumbImages(entry.thumbnail),
                isExpanded: false
            )
        }
    }
}
```

### 4️⃣ Implement the Delegate

Ensure that your view controller conforms to `DGGuideDelegate` (if required) and implement the necessary delegate methods.

```swift
//MARK:- EPG delegate methods
extension EPGViewController: DGGuideDelegate {
/// Implement delegate methods
    func didSelectItem(stream: String) {
    /// Function returns the selected channel stream url which is passed on to the view controller to fetch the playback url and m3u8 file is fed back into tv guide using data source methods
    }
    
    /// Optional function to hide tab bar controller if present
    func scrollViewDidScroll(shouldHideView: Bool) {
    }
}
//MARK:- EPG data source methods
extension EPGViewController: DGGuideDelegate {
    /// Function to return m3u8 url to TG Guide for playback
    func shouldStartPlayback() -> String? {
        
    }
    /// Function to set the TV Guide data
    func dataForItem() -> [GuideEntries]? {
        
    }

}
```

## 🎯 Conclusion

Now, when you call `setupTVGuide()` inside your `viewDidLoad()`, it will display the TV guide using the `DGProgramGuide` framework.

## 💡 Author

- **[Arjun Santhosh]**
- **[www.arjunsanthosh.com]**
