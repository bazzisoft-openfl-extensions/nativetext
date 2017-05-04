#ifndef NATIVETEXTFIELDCONFIG_H
#define NATIVETEXTFIELDCONFIG_H

#include <string>


namespace nativetext
{
    class NativeTextFieldConfig
    {
        public:
            enum TextAlignment 
            {
                TAL_NATURAL,
                TAL_LEFT,
                TAL_CENTER,
                TAL_RIGHT
            };
            
            enum KeyboardType
            {
                KB_DEFAULT,
                KB_PASSWORD,
                KB_DECIMAL,
                KB_NAME,
                KB_EMAIL,
                KB_PHONE,
                KB_URL
            };
            
            enum ReturnKeyType
            {
                RK_DEFAULT,
                RK_GO,
                RK_NEXT,
                RK_SEARCH,
                RK_SEND,
                RK_DONE
            };
        
        private:
            template <class T>
            class Option
            {
                public:
                    inline Option()
                    {
                        m_set = false;
                    }
                    
                    inline bool IsSet() const { return m_set; }
                    inline const T& Value() const { return m_value; }					
                    inline void Set(const T& value, bool condition = true)	{ m_set = condition; m_value = value; }
                
                private:
                    T 		m_value;
                    bool	m_set;
            };
            
        public:
            Option<double> x;
            Option<double> y;
            Option<double> width;
            Option<double> height;
            Option<bool> visible;
            Option<bool> enabled;
            Option<std::string> placeholder;
            Option<std::string> fontAsset;
            Option<int> fontSize;
            Option<int> fontColor;
            Option<int> placeholderColor;
            Option<int> backgroundColor;
            Option<TextAlignment> textAlignment;
            Option<KeyboardType> keyboardType;
            Option<ReturnKeyType> returnKeyType;
    };
}


#endif