# FlashCart
FlashCart⚡ is a Flutter app that leverages Google's Gemini AI to transform images of consumable products into a smart shopping list. 

## ⚠️ Disclaimer ⚠️

Before you run this app, please make sure to create a **vars.env** file in the root directory of this project. This file should contain your Google API key:

```bash
GOOGLE_API_KEY=YOUR_API_KEY
```
**Important:** Do NOT commit the `vars.env` file to your version control system (e.g., Git). It contains sensitive information that should be kept private.

## General Instructions

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

## Additional Tips:

* Experiment with different lighting conditions and angles when taking photos to find what works best.
* If FlashCart doesn't recognize a product, you can manually add a description by tapping the "Edit" icon next to the item.
* Take advantage of FlashCart's integration with Google services (if applicable) to enhance your shopping experience further.
