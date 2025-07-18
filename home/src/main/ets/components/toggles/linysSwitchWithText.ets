import { animation_default } from '../../hosts/bunch_of_defaults';
import linysText from '../texts/linysText';

@Component
struct linysSwitchWithText {
  // Links
  @Prop text: ResourceStr = "";
  @Link toggle_state: boolean;
  onExecution?: () => void;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand: string = 'right';
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Row({ space: 10 }) {
      Row() {
        linysText({ text: this.text, max_lines: 5 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)

      Toggle({ isOn: this.toggle_state, type: ToggleType.Switch })
        .switchPointColor(this.color_current_secondary)
        .selectedColor(this.color_current_font)
        .onChange(isOn => {
          this.toggle_state = isOn;
          if (this.onExecution) {
            this.onExecution();
          }
        })
    } // Toggle
    .direction(this.preferred_hand == 'right' ? Direction.Ltr : Direction.Rtl)
    .animation(animation_default())
    .width("100%")
  }
}

export default linysSwitchWithText;