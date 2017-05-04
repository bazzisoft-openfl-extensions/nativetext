package org.haxe.extension.nativetext;

import org.haxe.extension.extensionkit.HaxeCallback;
import org.haxe.extension.extensionkit.Trace;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import android.content.Context;
import android.text.InputType;
import android.util.TypedValue;
import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import java.io.UnsupportedEncodingException;
import android.util.Log;


class NativeTextField extends EditText implements View.OnFocusChangeListener
{
    private boolean m_eventsEnabled = false;
    private ViewGroup m_parentView;
    
    public NativeTextField(Context context, ViewGroup parentView, int eventDispatcherId)
    {
        super(context);
        
        m_parentView = parentView;
        
        setId(eventDispatcherId);
        setSingleLine(true);
        setBackgroundDrawable(null);
        setPadding(0, 0, 0, 0);

        SetReturnKeyType(NativeTextFieldReturnKeyType.Default);        

        RelativeLayout.LayoutParams rlp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        rlp.leftMargin = 0;
        rlp.topMargin = 0;

        setOnFocusChangeListener(this);

        m_parentView.addView(this, rlp);        
        m_eventsEnabled = true;
    }

    public void ConfigureFromJSON(final String jsonConfig)
    {
        final NativeTextFieldConfig config; 
        
        try 
        {
            GsonBuilder b = new GsonBuilder();
			b.registerTypeAdapter(Boolean.class, new NativeTextBooleanSerializer());
			Gson gson = b.create();
			
			config = gson.fromJson(jsonConfig, NativeTextFieldConfig.class);
            
            if (config.textAlignment != null)
            {
                config.textAlignmentEnum = NativeTextFieldAlignment.values()[config.textAlignment];
            }
            
            if (config.keyboardType != null)
            {
                config.keyboardTypeEnum = NativeTextFieldKeyboardType.values()[config.keyboardType];
            }
            
            if (config.returnKeyType != null)
            {
                config.returnKeyTypeEnum = NativeTextFieldReturnKeyType.values()[config.returnKeyType];
            }            
        }
        catch (Exception e)
        {
            Trace.Error("Invalid JSON recieved in NativeText.ConfigureTextField()");
            Trace.Error(jsonConfig);
            Trace.Error(e.toString());
            return;
        }
        
		if(config.fontAsset != null){
			Typeface t = Typeface.createFromAsset(getContext().getAssets(),config.fontAsset);
			setTypeface(t);
		}
        
        if (config.fontColor != null)
        {
            setTextColor(0xff000000 | config.fontColor);
        }
        
        if (config.fontSize != null)
        {
            setTextSize(TypedValue.COMPLEX_UNIT_PX, config.fontSize);
        }
        
        SetPositionAndSize(config.x, config.y, config.width, config.height);
        
        if (config.visible != null)
        {
            setVisibility(config.visible ? View.VISIBLE : View.GONE);
        }
        
        if (config.enabled != null)
        {
            setEnabled(config.enabled);
        }
        
        if (config.alpha != null)
        {
            setAlpha(config.alpha);
        }
        
        if (config.placeholder != null)
        {
            setHint(config.placeholder);
			
        }
		if(config.placeholderColor != null){
			setHintTextColor (config.placeholderColor);
		}
		if(config.backgroundColor != null){
			setBackgroundColor (config.backgroundColor);
		}
        SetTextAlignment(config.textAlignmentEnum);
        SetKeyboardType(config.keyboardTypeEnum);
        SetReturnKeyType(config.returnKeyTypeEnum);
    }    
    
    public String GetText()
    {
		return getText().toString();
    }
    
    public void SetText(String text)
    {
        m_eventsEnabled = false;
        setText(text);
        m_eventsEnabled = true;
    }
    
    public boolean IsFocused()
    {
        return isFocused();
    }
    
    public void SetFocus()
    {
        if (!isFocused() && requestFocus())
        {
            ShowKeyboard(true);
        }        
    }
    
    public void ClearFocus()
    {
        if (isFocused())
        {
            ShowKeyboard(false);
            clearFocus();
        }
    }
    
    @Override
    protected void onTextChanged(CharSequence text, int start, int lengthBefore, int lengthAfter) 
    {
        super.onTextChanged(text, start, lengthBefore, lengthAfter);

        if (m_eventsEnabled)
        {
            HaxeCallback.DispatchEventToHaxeInstance(
                    getId(),
                    "nativetext.event.NativeTextEvent", 
                    new Object[] {
                        "nativetext_change"
                    });
        }
    }
    
    @Override
    public void onEditorAction(int actionCode)
    {
        if (EditorInfo.IME_ACTION_NEXT == actionCode)
        {
            super.onEditorAction(actionCode);
        }
        else
        {
            ShowKeyboard(false);
            clearFocus();
        }
            
        HaxeCallback.DispatchEventToHaxeInstance(
                getId(),
                "nativetext.event.NativeTextEvent", 
                new Object[] {
                    "nativetext_return_key_pressed"
                });
    }
    
    @Override
    public void onFocusChange(View v, boolean hasFocus)
    {
        final String eventType = (hasFocus ? "nativetext_focus_in" : "nativetext_focus_out");
        
        HaxeCallback.DispatchEventToHaxeInstance(
                getId(),
                "nativetext.event.NativeTextEvent", 
                new Object[] {
                    eventType
                });
    }
    
    private void ShowKeyboard(boolean show)
    {
        InputMethodManager in = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        
        if (show)
        {
            in.showSoftInput(this, InputMethodManager.SHOW_IMPLICIT);
        }
        else
        {
            in.hideSoftInputFromWindow(getApplicationWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
    
    private void SetPositionAndSize(Float x, Float y, Float width, Float height)
    {
        RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) getLayoutParams();
        boolean layoutParamsModified = false;
        
        if (x != null)
        {
            layoutParams.leftMargin = Math.round(x);
            layoutParamsModified = true;
        }
        
        if (y != null)
        {
            layoutParams.topMargin = Math.round(y);
            layoutParamsModified = true;
        }
        
        if (width != null)
        {
            layoutParams.width = (width <= 0.0 ? RelativeLayout.LayoutParams.WRAP_CONTENT : Math.round(width));
            layoutParamsModified = true;
        }

        if (height != null)
        {
            layoutParams.height = (height <= 0.0 ? RelativeLayout.LayoutParams.WRAP_CONTENT : Math.round(height));
            layoutParamsModified = true;
        }
        
        if (layoutParamsModified)
        {
            setLayoutParams(layoutParams);
        }        
    }
    
    private void SetTextAlignment(NativeTextFieldAlignment textAlignment)
    {
        if (null == textAlignment)
        {
            return;
        }
        
        switch (textAlignment)
        {
            case Natural:
                setGravity(Gravity.TOP | Gravity.START);
                break;
                
            case Left:
                setGravity(Gravity.TOP | Gravity.LEFT);
                break;
                
            case Center:
                setGravity(Gravity.TOP | Gravity.CENTER_HORIZONTAL);
                break;
                
            case Right:
                setGravity(Gravity.TOP | Gravity.RIGHT);
                break;
        }
    }
    
    private void SetKeyboardType(NativeTextFieldKeyboardType keyboardType)
    {
        if (null == keyboardType)
        {
            return;
        }
        
        switch (keyboardType)
        {
            case Default:
                setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_NORMAL);
                break;
                
            case Password:
                setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
                break;
                
            case Decimal:
                setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL | InputType.TYPE_NUMBER_FLAG_SIGNED);
                break;
                
            case Name:
                setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PERSON_NAME | InputType.TYPE_TEXT_FLAG_CAP_WORDS);
                break;
                
            case Email:
                setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                break;
                
            case Phone:
                setInputType(InputType.TYPE_CLASS_PHONE);
                break;
                
            case URL:
                setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_URI);
                break;                    
        }
    }
    
    private void SetReturnKeyType(NativeTextFieldReturnKeyType returnKeyType)
    {
        if (null == returnKeyType)
        {
            return;
        }
        
        switch (returnKeyType)
        {
            case Default:
                setImeOptions(EditorInfo.IME_ACTION_UNSPECIFIED  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
            case Go:
                setImeOptions(EditorInfo.IME_ACTION_GO  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
            case Next:
                setImeOptions(EditorInfo.IME_ACTION_NEXT  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
            case Search:
                setImeOptions(EditorInfo.IME_ACTION_SEARCH  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
            case Send:
                setImeOptions(EditorInfo.IME_ACTION_SEND  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
            case Done:            
                setImeOptions(EditorInfo.IME_ACTION_DONE  | EditorInfo.IME_FLAG_NO_FULLSCREEN);
                break;
                
        }
    }
}
