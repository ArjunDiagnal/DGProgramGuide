//
//  File.swift
//  
//
//  Created by Arjun Santhosh on 10/02/25.
//



public struct GuideEntries: Decodable {
    public var id: String?
    public var guid: String?
    public var updated: Int?
    public var title: String?
    public var callSign: String?
    public var listings: [Listings]?
    public var upCominglistings: [Listings]?
    public var catchUplistings: [Listings]?
    public var thumbnail: TvGuideThumbnail?
    public var isExpanded: Bool

    // ✅ Public initializer (works only if all types are public)
    public init(
        id: String? = nil,
        guid: String? = nil,
        updated: Int? = nil,
        title: String? = nil,
        callSign: String? = nil,
        listings: [Listings]? = nil,
        upCominglistings: [Listings]? = nil,
        catchUplistings: [Listings]? = nil,
        thumbnail: TvGuideThumbnail? = nil,
        isExpanded: Bool = false
    ) {
        self.id = id
        self.guid = guid
        self.updated = updated
        self.title = title
        self.callSign = callSign
        self.listings = listings
        self.upCominglistings = upCominglistings
        self.catchUplistings = catchUplistings
        self.thumbnail = thumbnail
        self.isExpanded = isExpanded
    }
}

public struct TvGuideThumbnail : Codable {
    let url : String?
    let width : Int?
    let height : Int?
    let title : String?
    
    public init(
        url: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        title: String? = nil
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.title = title
    }
}

public struct Listings: Decodable {
    public var listingId: String?
    public var paId: String?
    public var title: String?
    public var description: String?
    public var startTime: Int?
    public var endTime: Int?
    public var seasonNumber: Int?
    public var programType: String?
    public var listingGuid: String?
    public var program: TVGuideProgram?
    public var dummyLiveEvent: String?
    public var isExpanded: Bool

    // ✅ Add a public initializer (if missing)
    public init(
        listingId: String? = nil,
        paId: String? = nil,
        title: String? = nil,
        description: String? = nil,
        startTime: Int? = nil,
        endTime: Int? = nil,
        seasonNumber: Int? = nil,
        programType: String? = nil,
        listingGuid: String? = nil,
        program: TVGuideProgram? = nil,
        dummyLiveEvent: String? = nil,
        isExpanded: Bool = false
    ) {
        self.listingId = listingId
        self.paId = paId
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.seasonNumber = seasonNumber
        self.programType = programType
        self.listingGuid = listingGuid
        self.program = program
        self.dummyLiveEvent = dummyLiveEvent
        self.isExpanded = isExpanded
    }
}


public struct TVGuideProgram: Codable {
    public var id: String?
    public var title: String?
    public var guid: String?
    public var description: String?
    public var longDescription: String?
    public var longTitle: String?
    public var programType: String?
    public var pubDate: String?
    public var ratings: [String]?
    public var secondaryTitle: String?
    public var shortDescription: String?
    public var shortTitle: String?
    public var image: [DummyImage]?

    // ✅ Add a public initializer
    public init(
        id: String? = nil,
        title: String? = nil,
        guid: String? = nil,
        description: String? = nil,
        longDescription: String? = nil,
        longTitle: String? = nil,
        programType: String? = nil,
        pubDate: String? = nil,
        ratings: [String]? = nil,
        secondaryTitle: String? = nil,
        shortDescription: String? = nil,
        shortTitle: String? = nil,
        image: [DummyImage]? = nil
    ) {
        self.id = id
        self.title = title
        self.guid = guid
        self.description = description
        self.longDescription = longDescription
        self.longTitle = longTitle
        self.programType = programType
        self.pubDate = pubDate
        self.ratings = ratings
        self.secondaryTitle = secondaryTitle
        self.shortDescription = shortDescription
        self.shortTitle = shortTitle
        self.image = image
    }
}

public struct DummyImage : Codable {
    let url : String?
    let width : Int?
    let height : Int?
    let title : String?
    
    public init(
        url: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        title: String? = nil
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.title = title
    }
}

