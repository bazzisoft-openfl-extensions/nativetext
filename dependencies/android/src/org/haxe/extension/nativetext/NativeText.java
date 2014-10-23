package org.haxe.extension.nativetext;

import org.haxe.extension.extensionkit.HaxeCallback;
import org.haxe.extension.extensionkit.Trace;

import com.google.gson.Gson;

import android.graphics.Typeface;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.RelativeLayout;


public class NativeText extends org.haxe.extension.Extension
{
    private static boolean s_initialized = false;
    private static ViewGroup s_textFieldView = null;
    
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
	}
	
	private static void Initialize()
	{
	    if (!s_initialized)
	    {
	        s_initialized = true;
	    
            mainActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mainActivity.setTheme(R.style.TextCursorDefault);
                    s_textFieldView = new RelativeLayout(mainActivity);
                    mainActivity.addContentView(s_textFieldView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                    
                    // Make sure native text fields don't have focus after click off
                    mainView.setOnTouchListener(new View.OnTouchListener() {
                        @Override
                        public boolean onTouch(View arg0, MotionEvent arg1) {
                            s_textFieldView.clearFocus();
                            return false;
                        }
                    });
                }
            });
	    }
	}
	
	public static void CreateTextField(final int eventDispatcherId, final String jsonConfig)
	{	    
        Initialize();
        
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (NativeText.FindTextFieldById(eventDispatcherId, true) != null)
                {
                    Trace.Error("NativeText: Trying to create a new EditText with a previously used ID (" + eventDispatcherId + "), skipping.");
                    return;
                }
                
                NativeTextField textField = new NativeTextField(mainActivity, s_textFieldView, eventDispatcherId);
                if (jsonConfig != null && jsonConfig != "")
                {
                    textField.ConfigureFromJSON(jsonConfig);
                }
            }
        });	    
	}

    public static void DestroyTextField(final int eventDispatcherId)
    {
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                View textField = NativeText.FindTextFieldById(eventDispatcherId);
                if (textField != null)
                {
                    s_textFieldView.removeView(textField);
                }
            }
        });
    }
    	
	public static void ConfigureTextField(final int eventDispatcherId, final String jsonConfig)
	{
	    mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run()
            {
                NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
                if (textField != null)
                {
                    textField.ConfigureFromJSON(jsonConfig);
                }                
            }
        });
	}

	public static String GetText(final int eventDispatcherId)
	{	    
        NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
        if (textField != null)
        {
            return textField.GetText();
        }
        else
        {
            return null;
        }
	}
	
    public static void SetText(final int eventDispatcherId, final String text)
    {
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
                if (textField != null)
                {
                    textField.SetText(text);
                }
            }
        });
    }
	
    public static boolean IsFocused(final int eventDispatcherId)
    {
        NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
        if (textField != null)
        {
            return textField.IsFocused();
        }
        else
        {
            return false;
        }
    }
    
    public static void SetFocus(final int eventDispatcherId)
    {
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
                if (textField != null)
                {
                    textField.SetFocus();
                }
            }
        });
    }    
    
    public static void ClearFocus(final int eventDispatcherId)
    {
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NativeTextField textField = NativeText.FindTextFieldById(eventDispatcherId);
                if (textField != null)
                {
                    textField.ClearFocus();
                }
            }
        });
    }    
    
	private static NativeTextField FindTextFieldById(final int eventDispatcherId)
	{
	    return FindTextFieldById(eventDispatcherId, false);
	}
	
    private static NativeTextField FindTextFieldById(final int eventDispatcherId, final boolean suppressWarning)
    {
        NativeTextField textField = (NativeTextField) s_textFieldView.findViewById(eventDispatcherId);
        
        if (!suppressWarning && null == textField)
        {
            Trace.Error("NativeText: Couldn't find text field with ID=" + eventDispatcherId);
        }           
        
        return textField;
    }	
}