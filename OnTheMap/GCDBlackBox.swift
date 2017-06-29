//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-09-02.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
