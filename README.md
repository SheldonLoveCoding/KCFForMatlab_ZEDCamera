# KCFForMatlab_ZEDCamera
This project implemented the function of object-tracking in real-time through Kernelized Correlation Filter (KCF), based on the code of https://github.com/scott89/KCF. 

And I added the interface of tracking the object through our own camera, ZED.

I modified the **run_tracker.m** ,and created **tracker2.m** according to **tracker.m**.  **tracker2.m** can achieve the function of calling the our camera and process the image we captured by the camera.

The usage is :

- Change the path in **run_tracker.m** and make sure that the path is right for your computer. 
- run the **run_tracker.m** ,click the catalogue of 'Camera' and press the button of 'OK'. 
- Then you will see a pitcure that the camera takes. Outline the object you want to track in the image through a rectangle. 
- Press the "Enter", and you can see the real-time tracking result.

Notice:

- Change the path in **run_tracker.m**.
- Make sure your camera is properly connected to the computer.



That's all. If you have some advice and confusion about this project, please e-mail me through liuxd_sheldon@163.com . I would appreciate it and try my best to help you. 
