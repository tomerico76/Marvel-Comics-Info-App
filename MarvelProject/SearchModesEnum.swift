//
//  SearchFieldInitialParameters.swift
//  MarvelProject
//
//  Created by tomer on 24/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

enum SearchMode{
    case characters
    case comics
    case creators
    case events
    case series
    case urls
    
    var description : String{
        switch self {
        case .characters: return "Characters"
        case .comics: return "Comics"
        case .creators: return "Creators"
        case .events: return "Events"
        case .series: return "Series"
        case .urls: return "Purchases"
        }
    }
    
    var startPoint : String{
        switch self {
        case .characters: return "characters"
        case .comics: return "comics"
        case .creators: return "creators"
        case .events: return "events"
        case .series: return "series"
        default: return ""
        }
    }
    
    var endPoint : String{
        switch self {
        case .characters: return "/characters"
        case .comics: return "/comics"
        case .creators: return "/creators"
        case .events: return "/events"
        case .series: return "/series"
        default: return ""
        }
    }
    
    var defaultSearchParameter : String{
        switch self {
        case .characters: return "nameStartsWith"
        case .comics: return "titleStartsWith"
        case .creators: return "nameStartsWith"
        case .events: return "nameStartsWith"
        case .series: return "titleStartsWith"
        default: return ""
        }
    }
    
    var placeHolder : String{
        switch self {
        case .characters: return "Character Name start with"
        case .comics: return "Comics Title start with"
        case .creators: return "Creators Name start with"
        case .events: return "Event name start with"
        case .series: return "Series Title start with"
        default: return ""
        }

    }
    
    var orderBy : [String]{
        switch self {
        case .characters: return ["name"]
        case .comics: return ["title", "issueNumber"]
        case .creators: return ["lastName", "firstName"]
        case .events: return ["name", "startDate"]
        case .series: return ["title", "startYear"]
        case .urls: return []
        }
    }

    var orderByDescription : [String]{
        switch self {
        case .characters: return ["Name"]
        case .comics: return ["Title", "Issue Number"]
        case .creators: return ["Last Name", "First Name"]
        case .events: return ["Name", "Start Date"]
        case .series: return ["Title", "Start Year"]
        case .urls: return []
        }
    }
    
    var type : Item.Type{
        switch self {
        case .characters: return CharactersItem.self
        case .comics: return ComicsItem.self
        case .creators: return CreatorsItem.self
        case .events: return EventsItem.self
        case .series: return SeriesItem.self
            default: return CharactersItem.self
        }
    }
        
    var detailsAvailableSearchModes : [SearchMode]{
        get{
            switch self {
            case .characters: return [.comics, .events, .series, .urls]
            case .comics: return [.characters, .creators, .events, .urls]
            case .creators: return [.comics, .events, .series, .urls]
            case .events: return [.characters, .comics, .creators, .series, .urls]
            case .series: return [.characters, .comics, .creators, .events, .urls]
            default : return []
            }
        }
    }
}
