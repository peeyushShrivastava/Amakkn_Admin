//
//  QRCodeGenerator.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 27/10/20.
//

import Foundation
import UIKit

class QRCodeGenerator {
    class func generateQRCode(for urlString: String) -> UIImage? {
        guard let data = urlString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")

        guard let qrcodeCGImage = filter.outputImage else { return nil }

        let scaleX = 200 / qrcodeCGImage.extent.size.width
        let scaleY = 200 / qrcodeCGImage.extent.size.height
        let transformedImage = qrcodeCGImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        let qrCodeImage = UIImage(ciImage: transformedImage)

        return qrCodeImage
    }
}
