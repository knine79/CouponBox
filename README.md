# CouponBox

This is my toy project to satisfing my desire. The applications about coupon(or gifticon) on the App Store are very annoying and commercial. They are recommnding some new coupons everyday.
But CouponBox is a very simple application that manages a list of coupons I already have. The imformations are stored only in local storage.
And I don't like to type all the informations of coupon, like product name, expiration date, etc. CouponBox automatically recognize these informations using computer vision.
And CouponBox notifies you of the coupon expiration date, so you don't have to miss out on using the coupon in the future.

The application architecture is intended to follow Robert C. Martin's Clean Architecture.

## Implemented features
* You can show a list of coupons.
* Automatically recognize text, expiration date, and barcode number from images that contain a barcode and add them to your coupon list.
* Shows the coupon image and allows you to edit the coupon data details.
* Provide push notifications on expiration date, 3 days before expiration, and 7 days before expiration.
* The app badge shows how many coupons are within 7 days of expiration.

## Features to implement
* Maximize screen brightness when a coupon image is displayed for scanning.
* The widget shows the coupon images in order of closest expiration date.
* Make soon-to-expire coupons more visible
