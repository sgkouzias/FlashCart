<div align="left">
  <img src="assets/icon/app_icon.png" alt="FlashCart Logo" width="150">
  <h1>FlashCart</h1>
</div>






Your AI-Powered Shopping Companion

## Disclaimer ⚠️ 

> This application was developed as a submission for the Gemini API Developer Competition. It is not intended for commercial use and is provided for demonstration purposes only.

## Attention❗

Before you run this app, please make sure to create a **vars.env** file in the root directory of this project. This file should contain your Google API key:

```bash
API_KEY=YOUR_API_KEY
```
**Caution:** Do NOT commit the `vars.env` file to your version control system (e.g., Git). It contains sensitive information that should be kept private.

## Setup

1. Create a new Flutter project: `flutter create <project_name>`
2. Clone this repository: `git clone <repository_url>`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Getting Started 

FlashCart makes your shopping experience easier by using artificial intelligence to generate product descriptions based on images. Here's how to use it:

1. Adding Photos:

* Tap the "Add Photos" button at the bottom of the screen.
* Select one or more photos of the products you want to add to your shopping list. You can select multiple images at once.
* FlashCart will automatically start processing the images.

2. Waiting for Descriptions:

* After you select photos, the app will briefly display a loading indicator.
* Please be patient while FlashCart generates descriptions for each product. This may take a few seconds depending on the number of images and the speed of your internet connection.

3. Viewing Your Shopping List:

* Once the descriptions are ready, they will appear in the "To Buy" tab, along with the images you selected.
* You can now easily check off items as you purchase them, and they will be moved to the "Purchased" tab.

## Additional Notes:

* **Image Quality:** For best results, try to take clear photos of the products, focusing on the labels and packaging.
* **Internet Connection:** FlashCart requires an internet connection to process images and generate descriptions.
* **Error Handling:** If there's an issue with image processing or description generation (e.g., due to a poor internet connection or an unrecognized product), you'll see an error message. You can usually retry the process.
* **Adding More Photos:** You can add more photos to your list at any time by tapping the "Add Photos" button again.
* **Removing Photos:** If you accidentally add a photo of a product you don't want on your list, simply swipe left or right on the item to remove it.

## Tips:

* Experiment with different lighting conditions and angles when taking photos to find what works best.
* **Edit Descriptions:** You can edit the description of any product, even if it was not generated automatically or if you want to revise it. Simply tap the "Edit" button next to the item and enter your own description. This is particularly useful if FlashCart doesn't recognize a product or if you want to add more specific details.
* **Capture the Details:** When taking pictures, make sure to capture the product's brand name, logo, and any other relevant details, just like you would if you were showing the image to a salesperson to purchase the item.


## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)