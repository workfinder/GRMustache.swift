//
//  NSFormatter.swift
//
//  Created by Gwendal Roué on 19/11/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

extension NSFormatter: ObjCMustacheBoxable {
    
    private func filter(box: MustacheBox, error: NSErrorPointer) -> MustacheBox? {
        if let object = box.value as? NSObject {
            return Box(self.stringForObjectValue(object))
        } else {
            return Box()
        }
    }
    
    private func render(info: RenderingInfo, error: NSErrorPointer) -> Rendering? {
        switch info.tag.type {
        case .Variable:
            // {{ formatter }}
            // Behave as a regular object: render self's description
            return Rendering("\(self)")
        case .Section:
            // {{# formatter }}...{{/ formatter }}
            // {{^ formatter }}...{{/ formatter }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            return info.tag.render(info.context.extendedContext(Box(self)), error: error)
        }
    }
    
    private func willRender(tag: Tag, box: MustacheBox) -> MustacheBox {
        switch tag.type {
        case .Variable:
            // {{ value }}
            
            if let object = box.value as? NSObject {
                // NSFormatter documentation for stringForObjectValue: states:
                //
                // > First test the passed-in object to see if it’s of the correct
                // > class. If it isn’t, return nil; but if it is of the right class,
                // > return a properly formatted and, if necessary, localized string.
                //
                // So nil result means that object is not of the correct class. Leave
                // it untouched.
                
                if let formatted = self.stringForObjectValue(object) {
                    return Box(formatted)
                }
            }
            return box
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            return box
        }
    }
    
    
    // MARK: - ObjCMustacheBoxable
    
    public override var mustacheBox: ObjCMustacheBox {
        return ObjCMustacheBox(Box(
            value: self,
            render: render,
            filter: Filter(filter),
            willRender: willRender))
    }
}