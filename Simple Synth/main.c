#include "main.h"


/* PSC and ARR values for various notes. */
//              Note:             <C>   C#   D    D#   E    F    F#   G    G#   A    A#   B    C
const uint16_t PSC_note[14] = {1, 219, 217, 256, 298, 404, 165, 187, 178, 300, 179, 130, 177, 138};
const uint16_t ARR_note[14] = {1, 139, 133, 106,  86,  60, 138, 115, 114,  64, 101, 131,  91, 110};

 volatile uint16_t buttons;

void SystemClock_Config(void);
void I2C_ERROR(void);
uint8_t I2C_READ (uint8_t sadd, uint8_t reg_addr);
void I2C_WRITE (uint8_t sadd, uint8_t reg_addr, uint8_t data);
uint16_t get_buttons(void);

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
	HAL_Init(); /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
	SystemClock_Config(); /* Configure the system clock */
  
	/* Initialize all configured peripherals */
	
	// Enable GPIOC
	RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
	
	/* LEDs and PWM*/
	// PC9 - Green	PC8 - Orange
	// PC7 - PWM    PC6 - PWM
	GPIOC->MODER   |= (0x5A << 12);  // General Purpose output mode, Alternate function mode
	GPIOC->OTYPER  &= ~(0xF << 6);   // Output push-pull
	GPIOC->OSPEEDR &= ~(0xFF << 12); // Low speed.
	GPIOC->PUPDR   &= ~(0xFF << 12); // No pull-up, pull-down
	
	GPIOC->AFR[0] &= ~(0xFF000000);
	/* 74HC165 Configuration */
	
	// Enable GPIOB
	RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
		
	// Use these pins with the board:
	// PB6 - Q7  (input)
	// PB5 - CE  (output)
	// PB4 - CLK (output) Low to High edge triggered
	// PB3 - PL  (output)
	GPIOB->MODER   |= (0x15 << 6);  // out, out, out, in
	GPIOB->OTYPER  &= ~(0xF << 3);  // Push-pull
	GPIOB->OSPEEDR &= ~(0xFF << 6); // Low Speed
	GPIOB->PUPDR   &= ~(0xFF << 6); // No pull-up, pull down on outputs
	GPIOB->PUPDR   |= (0x2 << 12);   // Pull-down on Q7
	
	buttons = 0;
	
	// Set CE, and PL high.
	GPIOB->ODR |= (0x5 << 3);
	
	/* I2C on GPIOB */
	// Enable I2C2
	RCC->APB1ENR |= RCC_APB1ENR_I2C2EN;
	// PB11 -> SDA (AF1), PB13 -> SCL (AF5)	
	GPIOB->MODER |= (0x1 << 28) | (0x2 << 26) | (0x2 << 22) | (0x1);
	GPIOB->OTYPER |= (0x5 << 11); // Output open-drain
	GPIOB->AFR[1] |= 0x00501000;
	
	// Set PB14 and PC0 to output mode, push-pull output type, and initialize it high.
	GPIOB->ODR |= (0x1 << 14); 
	GPIOC->ODR |= (0x1);
	
	// Use 100 kHz mode.
	I2C2->TIMINGR = 0x10420F13;
	I2C2->CR1 |= 0x1;
	
	I2C_WRITE(0x6B, 0x20, 0xB);
	
	// Enable TIM3 Clock
	RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;
	
	TIM3->PSC = PSC_note[0]; 
	TIM3->ARR = ARR_note[0];  
	
	TIM3->CCMR1 &= ~(0x3 << 8);   // Set channels to output
	TIM3->CCMR1 &= ~(0x3);
	TIM3->CCMR1 |= (0x7 << 4);               // Channel 1 to PWM mode 2
	TIM3->CCMR1 |= (0x6 << 12);              // Channel 2 to PWM mode 1
	TIM3->CCMR1 |= (0x1 << 11) | (0x1 << 3); // Enable output compare preload for both channels.
	
	TIM3->CCER |= (0x1 << 4) | (0x1);
	TIM3->CCR1 = 50; 
	TIM3->CCR2 = 50; 
	
	TIM3->CR1 |= 0x1;
	
	uint16_t prev_buttons = 0;
	
  while (1)
  {
		/* Gyro */
		int16_t x = (I2C_READ(0x6B, 0x29) << 8) | (I2C_READ(0x6B, 0x28));
		HAL_Delay(5); // Just magically makes it work.
		int16_t y = (I2C_READ(0x6B, 0x2B) << 8) | (I2C_READ(0x6B, 0x2A));
		
		x = x >> 13;
		y = y >> 13;
		
		/* Buttons */
		buttons = get_buttons();
		
		if(prev_buttons != buttons)
		{
			prev_buttons = buttons;
			TIM3->PSC = PSC_note[0];
			TIM3->ARR = ARR_note[0];
			TIM3->CR1 &= ~0x1;
		}
		else
		{
			switch(prev_buttons)
			{
				case 0x1:
				{
					TIM3->PSC = PSC_note[1] + x;
					TIM3->ARR = ARR_note[1] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x2:
				{
					TIM3->PSC = PSC_note[2] + x;
					TIM3->ARR = ARR_note[2] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x4:
				{
					TIM3->PSC = PSC_note[3] + x;
					TIM3->ARR = ARR_note[3] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x8:
				{
					TIM3->PSC = PSC_note[4] + x;
					TIM3->ARR = ARR_note[4] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x10:
				{
					TIM3->PSC = PSC_note[5] + x;
					TIM3->ARR = ARR_note[5] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x20:
				{
					TIM3->PSC = PSC_note[6] + x;
					TIM3->ARR = ARR_note[6] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x40:
				{
					TIM3->PSC = PSC_note[7] + x;
					TIM3->ARR = ARR_note[7] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x80:
				{
					TIM3->PSC = PSC_note[8] + x;
					TIM3->ARR = ARR_note[8] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x100:
				{
					TIM3->PSC = PSC_note[9] + x;
					TIM3->ARR = ARR_note[9] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x200:
				{
					TIM3->PSC = PSC_note[10] + x;
					TIM3->ARR = ARR_note[10] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x400:
				{
					TIM3->PSC = PSC_note[11] + x;
					TIM3->ARR = ARR_note[11] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x800:
				{
					TIM3->PSC = PSC_note[12] + x;
					TIM3->ARR = ARR_note[12] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				case 0x1000:
				{
					TIM3->PSC = PSC_note[13] + x;
					TIM3->ARR = ARR_note[13] + y;
					TIM3->CR1 |= 0x1;
					break;
				}
				default:
				{
					//TIM3->CR1 &= ~0x1;
				}		
			}
		}
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }
  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */



void I2C_ERROR(void)
{
	GPIOC->ODR &= ~(0xF << 6);
	while(1)
	{
		GPIOC->ODR ^= (0x1 << 6);
		HAL_Delay(500);
	}
}

uint8_t I2C_READ (uint8_t sadd, uint8_t reg_addr)
{
	I2C2->CR2 &= ~((0xFF << 16) | (0x7FF));
	
	// Set the slave address, the number of bytes to transmit, set Write Mode, set START Signal.
	I2C2->CR2 |= (0x1 << 16) | (sadd << 1);
	I2C2->CR2 |= I2C_CR2_START;
	
	// Wait for TXIS or NACKF flag
	while (!(I2C2->ISR & (I2C_ISR_TXIS | I2C_ISR_NACKF)));
	
	if (I2C2->ISR & I2C_ISR_NACKF)
		I2C_ERROR();
	
	// Write the address of the register into TXDR
	I2C2->TXDR = reg_addr;
	
	// Wait for TC Flag
	while(!(I2C2->ISR & I2C_ISR_TC));
	
	// Reload CR2.
	I2C2->CR2 &= ~((0xFF << 16) | (0x7FF));
	
	// Set the slave address again, this time read.
	I2C2->CR2 |= (1 << 16) | (0x1 << 10) | (sadd << 1);
	I2C2->CR2 |= I2C_CR2_START;
	
	// Wait for RXNE or NACKF flag
	while(!(I2C2->ISR & (I2C_ISR_RXNE | I2C_ISR_NACKF)));
	
	if (I2C2->ISR & I2C_ISR_NACKF)
		I2C_ERROR();
	
	// Wait for TC Flag
	while(!(I2C2->ISR & I2C_ISR_TC));

	// Set Stop Signal
	I2C2->CR2 |= I2C_CR2_STOP;
	
	
	return I2C2->RXDR;
}



void I2C_WRITE (uint8_t sadd, uint8_t reg_addr, uint8_t data)
{
	I2C2->CR2 &= ~((0xFF << 16) | (0x7FF));
	
	// Set the slave address, number of bytes, and a write instruction, and start.
	I2C2->CR2 |= (2 << 16) | (sadd << 1);
	I2C2->CR2 |= I2C_CR2_START;
	
	// Wait until either of the TXIS or NACKF flags are set.
	while (!(I2C2->ISR & (I2C_ISR_TXIS | I2C_ISR_NACKF)));
	
	// Error state.
	if (I2C2->ISR & I2C_ISR_NACKF)
		I2C_ERROR();
		
	// Write the address of the register into TXDR
	I2C2->TXDR = reg_addr;
		
	// Wait until either of the TXIS or NACKF flags are set.
	while (!(I2C2->ISR & (I2C_ISR_TXIS | I2C_ISR_NACKF)));
	
	// Error state.
	if (I2C2->ISR & I2C_ISR_NACKF)
		I2C_ERROR();
	
	I2C2->TXDR = data;
	
	// Wait until the TC flag is set.
	while(!(I2C2->ISR & I2C_ISR_TC));
	
	I2C2->CR2 |= (0x1 << 14);
}

uint16_t get_buttons(void)
{
	// Preamble (PL low, pulse clock, PL high)
	GPIOB->ODR &= ~(0x1 << 3);
	GPIOB->ODR |= (0x1 << 4);
	GPIOB->ODR |= (0x1 << 3);
	GPIOB->ODR &= ~(0x1 << 4);
	
	// Begin data transfer.
	GPIOB->ODR &= ~(0x1 << 5); // CE low
	GPIOB->ODR |= (0x1 << 4);  
	
	uint16_t temp;
	for(uint8_t i = 0; i < 15; i++)
	{
		GPIOB->ODR &= ~(0x1 << 4); 
		temp = (temp << 1); 
		temp |= (GPIOB->IDR & GPIO_IDR_6) >> 6;
		GPIOB->ODR |= (0x1 << 4);
	}
		
	// End data transfer.
	GPIOB->ODR &= ~(0x1 << 4);
	GPIOB->ODR |= (0x1 << 5);
		
	// Format the data (Want only 13 bits)
	return temp & 0x1FFF;
	
}

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
