//
//  ScreenshotProvider.swift
//  ToiletRace
//
//  Created by Enrico Castelli on 13/04/2020.
//  Copyright © 2020 Enrico Castelli. All rights reserved.
//

import UIKit
import Photos

protocol ScreenshotProvider {
    func willTakeScreenshot()
    func didTakeScreenShot()
}

extension ScreenshotProvider {

    func takeScreenshot() -> UIImage? {
        guard let layer = UIApplication.shared.windows.first?.layer else { return nil }
        willTakeScreenshot()
        var screenshotImage :UIImage?
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {
            didTakeScreenShot()
            return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        didTakeScreenShot()
        return screenshotImage
    }
}
